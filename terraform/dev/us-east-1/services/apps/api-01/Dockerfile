FROM python:3.10.12-alpine

WORKDIR /app
COPY .. /app

RUN pip3 install --no-cache-dir -r requirements.txt

EXPOSE 9555

HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:9555/healthz || exit 1

CMD ["python3", "app.py"]