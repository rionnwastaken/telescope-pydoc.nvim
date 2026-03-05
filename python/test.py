import inspect

def get_source_safe(obj):
    try:
        return inspect.getsource(obj)
    except (OSError, TypeError):
        return inspect.getdoc(obj)  # fallback to docstring


a = get_source_safe(int)
print(a)
