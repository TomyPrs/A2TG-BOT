FROM ghcr.io/tomyprs/aria2-mirror:master

# Install Python dependencies
ADD requirements.txt .
RUN pip3 install -U pip wheel setuptools && \
    pip3 install -r requirements.txt

# Set working directory
WORKDIR /app
# Mega sdk
ENV MEGA_SDK_VERSION '3.8.1'
RUN git clone https://github.com/meganz/sdk.git sdk && cd sdk \
    && git checkout v$MEGA_SDK_VERSION \
    && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl


# Copy from builder to working directory

COPY extract /usr/local/bin
COPY pextract /usr/local/bin
COPY . /app
RUN chmod +x /usr/local/bin/extract && chmod +x /usr/local/bin/pextract
COPY .netrc /root/.netrc
RUN chmod 600 /app/.netrc && chmod +x aria.sh

# Set command
CMD ["bash", "start.sh"]
