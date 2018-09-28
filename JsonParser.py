import sys
import json

def load_data(filepath):
    with open(filepath, 'r', encoding="utf-8") as the_file:
        return json.load(the_file)

if __name__ == '__main__':
    filepath = sys.argv[1]
    parsed_json = load_data(filepath)
    result = parsed_json['result']
    docs_list = result['Документ']
    for doc in docs_list:
        attachment_list = doc['Вложение']
        for att in attachment_list:
            print(att['Номер'])
			
