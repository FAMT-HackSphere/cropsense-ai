# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH /app/backend

# Copy the requirements file first to leverage Docker cache
COPY backend/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir httpx pytest

# Copy the entire project to the working directory
COPY . .

# Expose the API port
EXPOSE 8000

# Command to run the application
CMD ["python", "backend/run.py"]
