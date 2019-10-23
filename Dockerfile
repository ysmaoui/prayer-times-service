FROM python:3-alpine

COPY ./app /app

WORKDIR /app

bbbbblal

RUN pip install -r requirements.txt

ENTRYPOINT ["python"]

CMD ["app.py"]