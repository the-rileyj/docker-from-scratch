FROM alpine:latest

COPY test.txt .

RUN cat test.txt

RUN echo I can have multiple commands in one RUN build step by && \
        echo stringing commands togethor with '&&' to continue executing && \
        echo commands if the previous command succeeded without an error code && \
        echo and '\\' to escape the line break in the Dockerfile so you can have && \
        echo more than one line to put your commands on

CMD ["echo", "HI THERE!"]
