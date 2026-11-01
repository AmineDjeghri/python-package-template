"""Check the example's observable logging behavior."""


def test_hello_logs_greeting(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    from python_package_template.example import hello
    from python_package_template.settings import logger

    messages = []
    sink = logger.add(lambda message: messages.append(message.record["message"]))
    try:
        hello()
    finally:
        logger.remove(sink)

    assert messages == ["Hello world"]
