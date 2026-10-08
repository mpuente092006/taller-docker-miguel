# Etapa de construcción
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Etapa final
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY prestamos ./prestamos

RUN useradd --create-home appuser \
    && mkdir -p /app/datos \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:9000/salud')" || exit 1

CMD ["uvicorn", "prestamos.servidor:app", "--host", "0.0.0.0", "--port", "9000"]