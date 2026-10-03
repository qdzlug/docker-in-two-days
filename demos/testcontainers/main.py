from testcontainers.postgres import PostgresContainer
import sqlalchemy
import time

def print_hi(name):
    print(f'Hi, {name}')

if __name__ == '__main__':
    print_hi('Testcontainers ')

    # Postgres container
    with PostgresContainer("postgres:16") as postgres:
        psql_url = postgres.get_connection_url()
        engine = sqlalchemy.create_engine(psql_url)
        with engine.begin() as connection:
            version, = connection.execute(sqlalchemy.text("SELECT version()")).fetchone()
        print_hi(version)
        time.sleep(120)

