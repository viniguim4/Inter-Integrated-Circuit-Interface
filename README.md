# Inter-Integrated-Circuit-Interface

## TESTES
Para realização dos testes, usou-se uma FPGA e um microcontrolador. Na FPGA(DE-Nano) sintetizou-se a RTL descrita em i2cprimary.vhd na pasta src deste repositorio, em vista que para o microcontrolador (Arduino UNO), valeu-se do codigo em i2c_secondary_ino.ino também localizado na pasta src deste respositório. A associações dos pinos na FPGA se encontra no arquivo i2cvfinal.csv .

### Clique no vídeo.

[![Watch the video](https://img.youtube.com/vi/k9-YZpwUgVU/hqdefault.jpg)](https://www.youtube.com/embed/k9-YZpwUgVU)

O procedimento do vídeo também pode ser visualizado e explicado em um ambiente de simulação, conforme a análise da figura a seguir. Observa-se que há uma condição de início, logo a após segueo endereçamento e o modo (escrita ou leitura), seguido da troca de dados e uma condição final de parada.

![I2Canalysis](https://github.com/viniguim4/Inter-Integrated-Circuit-Interface/assets/127807875/5c5bc75a-0156-4337-97c0-e3a93342967a)
