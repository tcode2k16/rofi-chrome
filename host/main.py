#!/usr/bin/python2

import struct
import sys
import json
import subprocess

def send_message(message):
  sys.stdout.write(struct.pack('I', len(message)))
  sys.stdout.write(message)
  sys.stdout.flush()

def log(msg):
  pass

def call_rofi(param):
  options = param['opts']
  rofi_opts = ['rofi', '-dmenu']
  if 'rofi-opts' in param:
    rofi_opts.extend(param['rofi-opts'])

  sh = subprocess.Popen(rofi_opts, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
  sh.stdin.write('\n'.join(map(lambda x: x.encode('utf8'), options)))
  sh.stdin.flush()
  sh.stdin.close()

  return sh.stdout.read().strip()

def main():
  log('launched')
  while True:
    data_length_bytes = sys.stdin.read(4)

    if len(data_length_bytes) == 0:
      break
    
    data_length = struct.unpack('i', data_length_bytes)[0]
    data = sys.stdin.read(data_length).decode('utf-8')
    data = json.loads(data)
    log(data)
    
    cmd = data['cmd']
    param = data['param']
    info = data['info']
    if cmd == 'dmenu':
      output = {
        'cmd': 'dmenu',
        'result': call_rofi(param),
        'info': info
      }
    else:
      output = {
        'result': 'unknow command: {}'.foramt(cmd)
      }
    send_message(json.dumps(output))


  sys.exit(0)


if __name__ == '__main__':
  main()
