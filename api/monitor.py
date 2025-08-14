from opentelemetry.sdk.resources import SERVICE_NAME, Resource
import os
from dotenv import load_dotenv
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.metrics import set_meter_provider, get_meter_provider
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.trace import get_tracer_provider, set_tracer_provider
from opentelemetry.sdk.trace import TracerProvider
from fastapi import FastAPI
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
import logging
from functools import wraps

logger = logging.getLogger(__name__)

load_dotenv()
app_service_name = os.getenv('SERVICE_NAME', 'default_service')
oltp_endpoint = os.getenv('OLTP_ENDPOINT', 'localhost:4317')
oltp_insecure= os.getenv('OLTP_INSECURE', 'False').lower() == 'true'

def setup_metric():
    resource = resource=Resource.create({SERVICE_NAME: app_service_name})

    # Configure OpenTelemetry metrics exporter
    otlp_exporter = OTLPMetricExporter(
        endpoint=os.path.join(oltp_endpoint, 'v1/metrics'), 
        insecure= oltp_insecure
    )
    reader = PeriodicExportingMetricReader(otlp_exporter, export_interval_millis=5000)
    meter_provider = MeterProvider(resource=resource, metric_readers=[reader])
    set_meter_provider(meter_provider)

def setup_tracing():
    resource = resource=Resource.create({SERVICE_NAME: app_service_name})
    set_tracer_provider(TracerProvider(resource=resource))

    oltp_exporter = OTLPSpanExporter(
        endpoint=oltp_endpoint,
        insecure= oltp_insecure
    )

    span_processor = BatchSpanProcessor(oltp_exporter)
    get_tracer_provider().add_span_processor(span_processor)

def setup_monitoring(app: FastAPI):
    setup_metric()
    setup_tracing()
    FastAPIInstrumentor.instrument_app(app, tracer_provider=get_tracer_provider(), meter_provider=get_meter_provider())

def remove_monitoring(app: FastAPI):
    FastAPIInstrumentor.uninstrument_app(app)
    get_tracer_provider().shutdown()
    get_meter_provider().shutdown()

def trace(name, attributes=None):
    """
    Decorator to trace a function
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            tracer = get_tracer_provider().get_tracer(__name__)
            with tracer.start_as_current_span(name, attributes=attributes):
                return await func(*args, **kwargs)
        return wrapper
    return decorator