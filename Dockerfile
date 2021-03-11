FROM public.ecr.aws/a1p3q7r0/alpine:3.12.0 as ffmpeg-builder

RUN cd /usr/local/bin && \
    mkdir ffmpeg && \
    cd ffmpeg/ && \
    wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \
    tar xvf *.tar.xz && \
    rm -f *.tar.xz && \
    mv ffmpeg-git-*-amd64-static/ffmpeg .

FROM public.ecr.aws/lambda/provided:al2 as build
# install compiler
RUN yum install -y golang

# cache dependencies
ADD go.mod go.sum ./
RUN go mod download

# build
ADD . .
RUN go build -o /main
# copy artifacts to a clean image
FROM public.ecr.aws/lambda/provided:al2
COPY face3.mp4 ./
COPY --from=ffmpeg-builder /usr/local/bin/ffmpeg/ffmpeg /usr/local/bin/ffmpeg/ffmpeg
RUN ln -s /usr/local/bin/ffmpeg/ffmpeg /usr/bin/ffmpeg
COPY --from=build /main /main
ENTRYPOINT [ "/main" ]