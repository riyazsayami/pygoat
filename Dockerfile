# Use maintained base image (Debian 12 Bookworm)
FROM python:3.11-slim-bookworm

# Set working directory
WORKDIR /app

# Prevent Python writing .pyc files and buffer logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies needed for psycopg2 and DNS tools
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    # DNS utilities (dig/nslookup)
    dnsutils \
 && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY requirements.txt .

# Install Python dependencies
RUN python -m pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# Copy entire application source
COPY . .

# Apply database migrations
RUN python manage.py migrate

# Expose Django default port
EXPOSE 8000

# Run the app
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]