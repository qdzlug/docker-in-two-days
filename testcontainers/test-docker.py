from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs
import docker

def print_hi(name):
    print(f'Hi, {name}')

if __name__ == '__main__':
    print_hi('Testcontainers')

    # Using DockerContainer to run the hello-world image
    with DockerContainer("hello-world") as container:
        delay = wait_for_logs(container, "Hello from Docker!")
        print(f'Container started and log line detected: {delay}')

    # Building an image from a local Dockerfile
    client = docker.from_env()
    image, build_logs = client.images.build(path="./files", tag="test-image")

    print("Image built successfully. Logs:")
    for log in build_logs:
        print(log)

    # Running a container from the newly built image
    with DockerContainer("test-image") as container:
        # Assuming you have a specific log message to wait for in the new container
        delay = wait_for_logs(container, "Hello!")
        print(f'Container started from test-image and log line detected: {delay}')