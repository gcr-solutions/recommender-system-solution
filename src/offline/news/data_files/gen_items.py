import random
import re
regexp = re.compile(r'[&`><=@ω\{\}^#$/\]\[*【】Ⅴ；%+——「」｜…….:。\s？.：·、！《》!,，_~)）（(?“”"\\-]')

with open("item.csv", 'w') as item_out:
    with open("news_raw.csv") as item_in:
        while True:
            item_line = item_in.readline().strip()
            if item_line == "":
                break
            item_arr = item_line.split("_!_")
            title = item_arr[3]
            title_clean = regexp.sub("",  title)
            item_arr[3] = title_clean
            item_arr.append(str(random.randint(0, 10)))
            item_arr.append("0")
            item_out.write("_!_".join(item_arr) + "\n")
