# arch-primitive-ion

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

Set up as proxy, use the local ip address or (0.0.0.0, 127.0.0.1, localhost), port number is 7878 across these protocols HTTP, HTTPS, FTP & SOCKS.

**(( ! ))** You can close the Terminal that running the Docker Container, the arch-primitive will keep running at background, until you restart the system or the Docker services.

---

(C) Copyright EVAC Laboratories.
