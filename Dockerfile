# Use a lightweight Python base image (Python 3.11 is a safe, modern choice)
FROM python:3.11-slim

# Set environment variables for Python and the App
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0 \
    PORT=8000

# Install required system dependencies: FFmpeg and libsndfile1
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . /app/

# Install the Python application and its dependencies
# (We omit the -e editable flag here since it's a static container environment)
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir .

# Pre-create directories for model downloads and audio cache 
# so they can be easily mounted as persistent volumes
RUN mkdir -p /app/models /app/.cache_tts

# Run as a non-root user for better security
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Expose the default port
EXPOSE 8000

# Start the server using uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
