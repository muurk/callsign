FROM python:2.7
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
RUN python setup.py install
#ENTRYPOINT ["callsign-daemon", "start", "--no-divert", "-c", "/app/config.ini"]
ENTRYPOINT ["callsign-daemon","-c", "/app/callsign.conf"]
#ENTRYPOINT ["sleep", "500"]
