import ctypes


class PyperclipException(RuntimeError):
    pass


class PyperclipWindowception(PyperclipException):
    def __init__(self, message):
        message += " (%s)" % ctypes.WinError()
        super(PyperclipWindowception, self).__init__(message)
