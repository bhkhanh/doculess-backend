# |--------- BUILDER ----------|
FROM python:3.13-alpine AS builder

# set working directory
WORKDIR /usr/src

# enable these envs to optimize the Python image
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# install dependencies
RUN pip install -U pip --no-cache-dir
COPY requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir


# |---------- LOCAL ----------|
FROM python:3.13-alpine AS local

# copy installed packages from "builder" stage to current stage
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# set working directory
WORKDIR /usr/src

# enable these envs to optimize the Python image
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# copy all files to container
COPY . .

# set the default executable
ENTRYPOINT [ "python", "manage.py" ]

# default command/parameters that are executed when a container
# based on the image is started
CMD [ "runserver", "0.0.0.0:8000" ]


# |---------- PRODUCTION ----------|
FROM python:3.13-alpine AS production

# copy installed packages from "builder" stage to current stage
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# set working directory
WORKDIR /usr/src

# enable these envs to optimize the Python image
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# copy all files to container
COPY . .

# change permissions for script file
RUN chmod +x entrypoint.sh

# create another user
# don't run with root privileges
RUN adduser -D doculess_user
RUN chown -R doculess_user:doculess_user /usr/src

# switch the another user
USER doculess_user

# set the default executable
ENTRYPOINT [ "sh", "entrypoint.sh" ]
