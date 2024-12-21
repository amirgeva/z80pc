const char* input_names[] = {
  "CLK",
  "MREQ",
  "RD",
  "WR",
  "IORQ",
  "RESET",
  "CLEAR_WAIT",
  "A12"
};

const char* output_names[] = {
  "16",
  "17",
  "WAIT",
  "ROM",
  "MEM_RD",
  "MEM_WR",
  "RAM",
  "OE"
};

uint8_t inp, a15=1;

void read_output()
{
  uint8_t K = PINK;
  for(int i=2;i<8;++i)
  {
    if ((K & (1<<i))==0)
      Serial.print("!");
    Serial.print(output_names[i]);
    Serial.print(" ");
  }
  Serial.println("");
}

void print_input()
{
  for(int i=0;i<8;++i)
  {
    if ((inp & (1<<i))==0)
      Serial.print("!");
    Serial.print(input_names[i]);
    Serial.print(" ");
  }
  if (!a15) Serial.print("!");
  Serial.print("A15 ");
  Serial.print(" -> ");
}

void print_io()
{
  print_input();
  read_output();
}

void setup() {
  DDRF = 0xFF;
  PORTF = 0xFF;
  inp = 0xFF;
  DDRK = 0;
  DDRD = 1;
  PORTD |= 1;
  Serial.begin(115200);
  while (!Serial);
  print_io();
}

void process(String cmd)
{
  int space = cmd.indexOf(' ');
  if (space > 0)
  {
    String input = cmd.substring(0,space);
    String sval = cmd.substring(space+1);
    int value = sval.toInt();
    if (input == "A15")
    {
      if (value)
      {
        PORTD |= 1;
        a15=1;
      }
      else
      {
        PORTD &= ~1;
        a15=0;
      }
    }
    else
    {
      for(int i=0;i<8;++i)
      {
        if (input == input_names[i])
        {
          if (value)
          {
            PORTF |= (1 << i);
            inp |= (1 << i);
          }
          else
          {
            PORTF &= ~(1 << i);
            inp &= ~(1 << i);
          }
          break;
        }
      }
    }
  }
}

String incoming;

void loop() {
  if (Serial.available() > 0)
  {
    char c=Serial.read();
    if (c==10 || c==13)
    {
      incoming.trim();
      if (incoming.length()>0)
      {
        process(incoming);
        for(int i=0;i<4;++i)
        {
          process("CLK 1");
          process("CLK 0");
        }
        incoming="";
        print_io();
      }
    }
    else
    {
      incoming+=c;
    }
  }
}
