import unittest
import sqlalchemy
from testcontainers.postgres import PostgresContainer

container = PostgresContainer("postgres:16")
container.start()

psql_url = postgres.get_connection_url()
engine = sqlalchemy.create_engine(psql_url)

connection_url = container.get_connection_url()
conn = psycopg2.connect(connection_url)
cursor = conn.cursor()

version, = connection.execute(sqlalchemy.text("SELECT version()")).fetchone()


class MyTestCase(unittest.TestCase):
    def test_postgres_version(self):
        cursor.execute('SELECT version()')
        result = cursor.fetchone()
        self.assertIsNotNone(result)


## cursor.close()
## conn.close()
## container.stop()