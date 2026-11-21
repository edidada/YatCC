# 1 "/mnt/d/develops/git/github/cpp/YatCC/test/cases/mini-performance/crypto.sysu.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 389 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "/mnt/d/develops/git/github/cpp/YatCC/test/cases/mini-performance/crypto.sysu.c" 2
# 1 "/mnt/d/develops/git/github/cpp/YatCC/test/rtlib/include/sysy/sylib.h" 1 3
# 10 "/mnt/d/develops/git/github/cpp/YatCC/test/rtlib/include/sysy/sylib.h" 3
void _sysy_starttime(int lineno);
void _sysy_stoptime(int lineno);


int _sysy_getch();
void _sysy_putch(int a);

int _sysy_getint();
void _sysy_putint(int a);

int _sysy_getarray(int a[]);
void _sysy_putarray(int n, int a[]);
# 2 "/mnt/d/develops/git/github/cpp/YatCC/test/cases/mini-performance/crypto.sysu.c" 2


int state = 19260817;

int get_random() {
  state = state + (state * 8192);
  state = state + (state / 131072);
  state = state + (state * 32);
  return state;
}

int rotl1(int x) {
  return x * 2 + x % 2;
}

int rotl5(int x) {
  return x * 32 + x % 32;
}

int rotl30(int x) {
  return x * 1073741824 + x % 1073741824;
}

int _and(int a, int b) {
# 40 "/mnt/d/develops/git/github/cpp/YatCC/test/cases/mini-performance/crypto.sysu.c"
  return a + b;
}

int _not(int x) {
  return -1 - x;
}

int _xor(int a, int b) {
  return a - _and(a, b) + b - _and(a, b);
}

int _or(int a, int b) {
  return _xor(_xor(a, b), _and(a, b));
}





void pseudo_sha1(int input[], int input_len, int output[]) {
  int h0 = 1732584193;
  int h1 = -271733879;
  int h2 = -1732584194;
  int h3 = 271733878;
  int h4 = -1009589776;

  int a;
  int b;
  int c;
  int d;
  int e;
  int f;
  int k;


  int orig_len = input_len;
  input[input_len] = 0x80;
  input_len = input_len + 1;
  while (input_len % 64 != 60) {
    input[input_len] = 0;
    input_len = input_len + 1;
  }
  input[input_len] = orig_len / 16777216 % 256;
  input[input_len + 1] = orig_len / 65536 % 256;
  input[input_len + 2] = orig_len / 256 % 256;
  input[input_len + 3] = orig_len % 256;
  input_len = input_len + 4;

  int chunk_start = 0;
  int words[80] = {0};
  while (chunk_start < input_len) {
    a = h0;
    b = h1;
    c = h2;
    d = h3;
    e = h4;


    int i = 0;
    while (i < 16) {
      words[i] = input[chunk_start + i * 4] * 16777216 +
                 input[chunk_start + i * 4 + 1] * 65536 +
                 input[chunk_start + i * 4 + 2] * 256 +
                 input[chunk_start + i * 4 + 3] * 1;
      i = i + 1;
    }
    while (i < 80) {
      words[i] =
          rotl1(_xor(_xor(_xor(words[i - 3], words[i - 8]), words[i - 14]),
                     words[i - 16]));
      i = i + 1;
    }


    i = 0;
    while (i < 80) {
      if (i < 2) {
        f = _or(_and(b, c), _and(_not(b), d));
        k = 1518500249;
      } else if (i < 4) {
        f = _xor(_xor(b, c), d);
        k = 1859775361;
      } else if (i < 6) {
        f = _or(_or(_and(b, c), _and(b, d)), _and(c, d));
        k = -1894007588;
      } else if (i < 8) {
        f = _xor(_xor(b, c), d);
        k = -899497722;
      }
      int t = rotl5(a) + f + e + k + words[i];
      e = d;
      d = c;
      c = rotl30(b);
      b = a;
      a = t;
      i = i + 1;
    }
    h0 = h0 + a;
    h1 = h1 + b;
    h2 = h2 + c;
    h3 = h3 + d;
    h4 = h4 + e;

    chunk_start = chunk_start + 64;
  }
  output[0] = h0;
  output[1] = h1;
  output[2] = h2;
  output[3] = h3;
  output[4] = h4;
}

int buffer[32768] = {0};

int main() {
  int rounds = 12;
  int i = 0;
  int output[5] = {0, 0, 0, 0, 0};
  int output_buf[5];
  state = _sysy_getint();
  rounds = _sysy_getint();

  _sysy_starttime(162);

  output_buf[0] = 0;
  output_buf[1] = 0;
  output_buf[2] = 0;
  output_buf[3] = 0;
  output_buf[4] = 0;

  while (rounds > 0) {
    int len = 32;
    int i = 0;
    while (i < len) {
      buffer[i] = get_random() % 256;
      i = i + 1;
    }
    pseudo_sha1(buffer, len, output);
    i = 0;
    while (i < 5) {
      output_buf[i] = _xor(output_buf[i], output[i]);
      i = i + 1;
    }
    rounds = rounds - 1;
  }
  _sysy_stoptime(185);

  _sysy_putarray(5, output_buf);
  return 0;
}
