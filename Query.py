from distutils.util import execute
import sqlite3
import sys

conn = sqlite3.connect('zombie.db')
c = conn.cursor()


def Query(text):
  c.execute(text)
  conn.commit()

def FetchQuery(text = ''):
  c.execute(f"SELECT * FROM zombieLog {text}")

  command = c
  if text == '':
    command = c.fetchall()


  zombieNum = 0
  for zombie in command:
    itemNum = 0
    for item in zombie:
      if itemNum == 0:
        print(f"Name: {item}")
      elif itemNum == 1:
        print(f"Age: {item}")
      elif itemNum == 2:
        print(f"Type: {item}")
      elif itemNum == 3:
        print(f"Location: {item}")
      elif itemNum == 4:
        print(f"Speciality: {item}")
      elif itemNum == 5:
        print(f"Eats Brains: {item}")

      itemNum+=1

    print("\n")

if __name__ == "__main__":
  funct = str(sys.argv[1])
  text = str(sys.argv[2])

  if funct == "fetch":
    FetchQuery(text)
  elif funct == "query":
    Query(text)
  