import io
from testcontainers.minio import MinioContainer
import testcontainers


def print_hi(name):
    print(f'Hi, {name}')

if __name__ == '__main__':
    print_hi('Testcontainers ')


    with MinioContainer() as minio:
        client = minio.get_client()
        client.make_bucket("test")
        test_content = b"Hello World"
        write_result = client.put_object(
            "test",
            "testfile.txt",
            io.BytesIO(test_content),
            length=len(test_content),
        )
        retrieved_content = client.get_object("test", "testfile.txt").data
        print_hi(retrieved_content)