FROM python:3.11.3-bullseye as builder

ENV WEB_CONCURRENCY 2
ENV LANGUAGE_MODEL en_core_web_sm

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache
RUN pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
RUN pip install poetry==1.5.1 -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN poetry source add --priority=default mirrors https://pypi.tuna.tsinghua.edu.cn/simple/
RUN poetry install --without dev --no-root && rm -rf $POETRY_CACHE_DIR

# Download language model. Can be changed to a different model via config or env variable
RUN poetry run python -m spacy download ${LANGUAGE_MODEL}

FROM python:3.11.3-slim-bullseye as runtime

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY ./models/moka-ai_m3e-base /root/.cache/torch/sentence_transformers/moka-ai_m3e-base
COPY ./app /app/app
COPY config.yaml /app
COPY main.py /app

WORKDIR /app

ENTRYPOINT ["python", "main.py"]
