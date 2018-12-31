# arch-primitive-ion

**!! (rebooted version for IntelliJ IDEA IDE) !!**

Ultra high performance network relay for embedded system **(commercially obsolete)**

- **(new)** Ionizer (block unwanted object) (patterns updated regulary)
- **(new)** 3x acceleration

> You might also want to chech the previous version [**arch-primitive**](https://github.com/loouislow81/arch-primitive)

---

### Prerequisites

Comes with easy automation scripts.

- **primitive-ion.sh** _(build, clean, run)_
- **link.sh** _(iptables)_

The `primitive-ion.sh` will automatically install necessary components for you, each time you _**build**_, _**clean**_ or _**run**_ the package.

(( ! )) Extra 600MB maven components will be installed.

(( ? )) **Main Source** is located at `/arch-primitive-ion/src/main`.

(( ? )) **Unit-Test** is located at `/arch-primitive-ion/src/test`.

(( ? )) **Ionizer** more than 65000+ Blocklist (hardocded)

---

### Build & Test

Packed with unit-tests, if you have made some changes in the actual code, you might want to write your own unit-test to make sure all your new functions are actually working.

**Note:** _Recommended to compile the `arch-primitive` with server CPUs_

```bash
$ ./primitive-ion.sh --build
```

### Clean Package

This will restore to original, removed ssl certificates, surefire reports, etc.

```bash
$ ./primitive-ion.sh --clean
```

### Run the package

Oh! Before you run the package, you need to change the path in the `primitive-ion.sh` file. And the same to Docker Container, if you want to create an image manually. Example at below.

```bash
######## vars ##########

# path
fullPath="/home/$USER/Documents/play/playground/arch-primitive-ion"
```

**Note:** _Recommended to test the `arch-primitive` with server CPUs_

```bash
$ ./primitive-ion.sh --run
```

Use the nerd way,

```bash
$ java -XX:+HeapDumpOnOutOfMemoryError -Xmx1024m -jar target/arch-primitive-ion-0.9.7.5-SNAPSHOT-evaclabs.jar
```

### Use Docker Image

Pull image from Docker Hub,

```bash
$ docker pull loouislow81/arch-primitive-ion
```

Run the container

```bash
$ docker run -it -p 7878:7878 loouislow81/arch-primitive-ion
```

If you can't get the Docker Container fired up (but usually 100% worked), use the nerd way:

```bash
$ iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 7878 -j DNAT --to-destination 172.17.0.2:7878

```

Run the container as system boot up forever,

```bash
$ docker run --restart=always -p 7878:7878 loouislow81/arch-primitive-ion /bin/bash /home/arch-primitive/primitive-ion.sh -r
```

Remove the container,

```bash
$ docker rmi -f loouislow81/arch-primitive-ion:latest
```

Set up as proxy, use the local ip address or (0.0.0.0, 127.0.0.1, localhost), port number is 7878 across these protocols HTTP, HTTPS, FTP & SOCKS.

**(( ! ))** You can close the Terminal that running the Docker Container, the arch-primitive will keep running at background, until you restart the system or the Docker services.

---

(C) Copyright EVAC Laboratories.

---

MIT License

Copyright (c) 2018 Loouis Low

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
