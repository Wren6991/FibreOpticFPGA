def approx_ratio(ratio, tolerance):
    p, q = 1, 1
    history = [1]
    while abs((p / q) / ratio - 1) > tolerance:
        if p / q > ratio:
            q += 1
        else:
            p += 1
        history.append(p/q)
    return ((p, q), history)
