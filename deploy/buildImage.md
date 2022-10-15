# build image
docker build -t gyb/janus:1.0.0 -f Dockerfile .

# run container
 docker run -itd --privileged=true --name gybJanusServer --restart=always --net=host -p 8188:8188 -p 8989:8989 gyb/janus:1.0.0

