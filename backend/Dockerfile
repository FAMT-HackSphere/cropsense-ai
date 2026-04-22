# Use slim python image for faster builds and deployments
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies if any (none required for current scikit-learn/pandas setup)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
# We copy models/ and app/ and main.py
COPY . .

# Expose port (Cloud Run will define this via $PORT)
# The application must listen on 0.0.0.0
# The port is technically arbitrary inside the container as long as uvicorn picks it up

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Command to run uvicorn
# We use run.py or run uvicorn direct. Cloud Run passes PORT env var.
CMD ["python", "run.py"]
