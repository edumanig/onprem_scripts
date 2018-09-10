import datetime
import time


def elapsed_interval(start,end):
    elapsed = end - start
    min,secs=divmod(elapsed.days * 86400 + elapsed.seconds, 60)
    hour, minutes = divmod(min, 60)
    return '%.2d:%.2d:%.2d' % (hour,minutes,secs)

if __name__ == '__main__':
    time_start=datetime.datetime.now()

    """ do your process """

    time.sleep(10)
    time_end=datetime.datetime.now()
    total_time=elapsed_interval(time_start,time_end)
    print(total_time)
