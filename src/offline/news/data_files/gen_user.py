import random
import time
import uuid

N = 0
with open('user.csv', "w") as out:
    while N < 1000:
        N = N + 1
        user_id = str(uuid.uuid1())
        sex = random.choices(["M", "F"], weights=[4, 6])[0]
        age = random.choices([12, 18, 25, 35, 48, 59, 65, 75],
                             weights=[1, 3, 5, 5, 4, 4, 2, 1])[0] + random.randint(-3, 3)
        register_time = int(time.time()) - random.randint(3600 * 24 * 10, 3600 * 24 * 30)
        user_info = [user_id, str(sex), str(age), str(register_time)]
        line = "_!_".join(user_info)
        out.write(line + "\n")
