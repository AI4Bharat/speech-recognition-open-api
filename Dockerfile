FROM gcr.io/ekstepspeechrecognition/speech-recognition-open-api-dependency:4.4


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y sudo wget python3-pip git

RUN mkdir /opt/speech_recognition_open_api/
ENV base_path=/opt/speech_recognition_open_api/
ENV models_base_path=/opt/speech_recognition_open_api/deployed_models/
ENV model_logs_base_path=/opt/speech_recognition_open_api/deployed_models/logs/
ENV TRANSFORMERS_CACHE=/opt/speech_recognition_open_api/deployed_models/model_data/transformers_cache/
ENV DENOISER_MODEL_PATH=/opt/speech_recognition_open_api/deployed_models/model_data/denoiser/denoiser_dns48.pth
ENV UTILITIES_FILES_PATH=/opt/files/
COPY requirements.txt /opt/speech_recognition_open_api/
RUN echo "export LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/lib" >> ~/.bashrc
RUN pip3 install --no-cache-dir -r /opt/speech_recognition_open_api/requirements.txt
RUN pip3 uninstall -y fairseq
RUN git clone https://github.com/AI4Bharat/fairseq.git && cd fairseq && pip install --editable ./
WORKDIR /opt/speech_recognition_open_api/
COPY . /opt/speech_recognition_open_api
RUN cp -r /opt/files/denoiser /opt/speech_recognition_open_api/denoiser
CMD ["python3","/opt/speech_recognition_open_api/server.py"]

