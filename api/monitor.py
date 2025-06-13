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
APP_SERVICE_NAME = os.getenv('SERVICE_NAME', 'default_service')
OLTP_ENDPOINT = os.getenv('OLTP_ENDPOINT', 'localhost:4317')
OLTP_INSECURE= os.getenv('OLTP_INSECURE', 'False').lower() == 'true'

logger.info(f"Service Name: {APP_SERVICE_NAME}")
logger.info(f"OTLP Endpoint: {OLTP_ENDPOINT}")
logger.info(f"OTLP Insecure: {OLTP_INSECURE}")

def setup_metric():
    resource = resource=Resource.create({SERVICE_NAME: APP_SERVICE_NAME})

    # Configure OpenTelemetry metrics exporter
    otlp_exporter = OTLPMetricExporter(
        endpoint=os.path.join(OLTP_ENDPOINT, 'v1/metrics'), 
        insecure= OLTP_INSECURE
    )
    reader = PeriodicExportingMetricReader(otlp_exporter, export_interval_millis=5000)
    meter_provider = MeterProvider(resource=resource, metric_readers=[reader])
    set_meter_provider(meter_provider)

    return

def setup_tracing():
    resource = resource=Resource.create({SERVICE_NAME: APP_SERVICE_NAME})
    set_tracer_provider(TracerProvider(resource=resource))

    oltp_exporter = OTLPSpanExporter(
        endpoint=OLTP_ENDPOINT,
        insecure= OLTP_INSECURE
    )

    span_processor = BatchSpanProcessor(oltp_exporter)
    get_tracer_provider().add_span_processor(span_processor)

def setup_monitoring(app: FastAPI):
    setup_metric()
    setup_tracing()
    FastAPIInstrumentor.instrument_app(app, tracer_provider=get_tracer_provider(), meter_provider=get_meter_provider())
    return 

def remove_monitoring(app: FastAPI):
    FastAPIInstrumentor.uninstrument_app(app)
    get_tracer_provider().shutdown()
    get_meter_provider().shutdown()
    return

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