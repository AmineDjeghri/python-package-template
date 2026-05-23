# Run ``make docker-dev`` from the root of the project


# Define an argument for the Python version, defaulting to 3.11 if not provided.
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}
LABEL authors="amine"

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1
# output is written directly to stdout or stderr without delay, making logs appear immediately in the console or in log files.
ENV PYTHONUNBUFFERED=1

# keep this in case some commands use sudo (tesseract for example). This docker doesn't need a password
#RUN apt-get update &&  apt-get install -y sudo && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the source code into the container (the dockerfile is in a folder namled docker)
COPY ../ .

# Install dependencies using uv
# we didn't add a non root user because the install-dev uses root for tesseract
RUN make install-dev

CMD ["bash"]
