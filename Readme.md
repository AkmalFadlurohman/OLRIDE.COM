# Tugas 3 IF3110 Pengembangan Aplikasi Berbasis Web

## Deskripsi Singkat
PR-OJEK adalah aplikasi ojek online berbasis web memungkinkan seorang pengguna untuk menjadi penumpang dan/atau driver ojek online. Untuk menggunakan aplikasi ini, seorang pengguna harus melakukan login. Pengguna dapat menjadi penumpang maupun driver pada akun yang sama. Untuk menjadi driver, pengguna harus mengaktifkan opsi menjadi driver pada profilnya.
Seorang driver yang akan mencari order harus mengaktifkan statusnya agar dapat menjadi visible ketika ada user lain yang akan mencari ojek. Pengguna dapat saling bertukar pesan dengan driver secara realtime di halaman order chat driver.

## Anggota Tim
* **13515074 - Akmal Fadlurohman** <br />
* **13515083 - Muhammad Hilmi Asyrofi** <br />
* **13515146 - Fadhil Imam Kurnia** <br />

## Arsitektur Umum

Berikut gambaran arsitektur umum sistem:

![](img/arsitektur_umum.png)

### Deskripsi Sistem
Sistem ini merupakan pengembangan lanjutan dari sistem PR-Ojek tahap sebelumnya. Perbedaaan dengan tahap sebelumnya terletak pada perubahan pada fungsionalitas order, peningkatan security, dan tambahan fitur chat yang menghubungkan antara customer dan driver. <br /> 
Fitur chat diimplementasikan menggunakan MEAN Stack. REST service untuk keperluan chatting pada sistem ini diimplementasikan dengan Node dan Express. Selain itu, Firebase Cloud Messaging juga digunakan dalam implementasi PR-OJEK pada bagian chat. Data history chat disimpan dalam basis data MongoDB.

## Fungsionalitas Tambahan

### Security
### Finding Order
### Chat Pengguna

![](img/mekanisme_chat.png)

Proses untuk komunikasi antar client adalah sebagai berikut:
1. Ketika client dijalankan, client akan meminta token (token yang berbeda dengan token untuk authentication dari Identity Service) dari FCM.
2. FCM mengirimkan token ke client.
3. Setelah token diterima, client akan mengirim token serta identitas dari client (nama/email) ke chat server. Identitas client digunakan untuk mengidentifikasi kepemilikan token.
4. Untuk mengirim pesan kepada client lain, client pertama mengirimkan pesan yang berisi identitas pengirim, identitas tujuan, dan isi pesan ke chat server.
5. Chat server kemudian akan mencari token yang terkait dengan identitas tujuan.
6. Chat server lalu mengirim request ke FCM untuk mengirimkan pesan kepada client dangan token yang terkait.
7. FCM mengirimkan pesan kepada tujuan.

### Asumsi yang Digunakan
1. Pada tugas ini, diasumsikan kedua client sedang aktif. Aplikasi hanya akan dijalankan pada localhost, sehingga memerlukan 2 browser yang berbeda untuk mensimulasikan client yang berbeda. Aplikasi berjalan pada localhost karena browser mensyaratkan sumber aplikasi harus aman untuk operasi-operasi yang digunakan pada aplikasi ini. Localhost termasuk lokasi yang diperbolehkan oleh browser.
2. Kedua browser tersebut harus dalam keadaan aktif dan terfokus, serta tidak terminimize. Hal ini karena cara kerja service worker, yang hanya dapat memberikan notifikasi, dan tidak dapat melakukan manipulasi halaman apabila web browser tidak sedang terfokus ketika pesan datang.
Selain itu, seorang pengguna hanya dapat chatting dengan 1 pengguna lain dalam 1 waktu, sehingga hanya 1 kotak chat yang ditampilkan.
3. Driver hanya dapat menerima satu order dari satu user pada satu waktu.

### Skenario Chatting
Skenario penggunaan aplikasi adalah sebagai berikut.
Misal pengguna A adalah non driver, dan pengguna B adalah driver.
1. A dan B login untuk masuk ke aplikasi.
2. B melakukan finding order pada halaman Order. A memasuki halaman Order.
3. A melakukan order dan memilih driver yang sedang online dan tersedia (driver B).
4. Kotak chat akan muncul di halaman Chat Driver pada layar A. Kotak chat juga akan muncul pada halaman Order pada B.
5. A mengetikkan pesan, dan menekan tombol kirim.
6. Pesan dikirim ke B melalui chat server dan FCM.
7. Ketika pesan sudah diterima di B, kotak chat pada layar B akan muncul.
8. B dapat membalas chat dari A.
9. Apabila A sudah melakukan submit rating maka chatbox pada B akan hilang dan kembali menampilkan halaman finding order.

### Skenario Umum Program
Skenario program selain chat, pada umumnya sama seperti tugas 2. Akan tetapi, metode pengecekan token pada identity service sedikit berbeda.

Identity Service harus mengecek:
1. Apakah access token ini sudah kadaluarsa?
2. Apakah access token ini digunakan pada browser yang berbeda?
3. Apakah access token ini digunakan dengan koneksi internet yang berbeda?

Jika jawaban salah satu pertanyaan tersebut adalah "ya", maka identity service akan memberikan respon error dan detail errornya.

### Tampilan Program
Halaman Order pada Driver

![](img/driver_halaman_order.png)

Halaman Order pada Driver Ketika Melakukan Finding Order

![](img/driver_finding_order.png)

Halaman Order pada Driver Ketika Mendapat Order

![](img/driver_got_order.png)

Halaman Order pada Pengguna, Chat Driver

![](img/pengguna_chat_driver.png)

Perlu diperhatikan bahwa chat yang dikirim oleh user yang sedang login berada disisi sebelah kanan dan lawan chatnya lain di sisi sebelah kirim. Isi chat jga harus ditampilkan sesuai urutan waktu diterima (paling atas adalah chat paling lama dan makin ke bawah chat makin baru).

### Referensi Terkait
Berikut adalah referensi yang dapat Anda baca terkait tugas ini:
1. https://firebase.google.com/docs/web/setup
2. https://firebase.google.com/docs/cloud-messaging/js/client
3. https://docs.angularjs.org/api


Selain itu, silahkan cari "user agent parser", "how to get my IP from HTTPServletRequest", dan "HTTP Headers field" untuk penjelasan lebih lanjut.


### Prosedur Demo
Sebelum demo, asisten akan melakukan checkout ke hash commit terakhir yang dilakukan sebelum deadline. Hal ini digunakan untuk memastikan kode yang akan didemokan adalah kode yang terakhir disubmit sebelum deadline
<br />
<br />


### Pembagian Tugas

Chat App Front-end :
1. Fungsionalitas A : 135140XX  
2. Fungsionalitas B : 135140XX  


Chat REST Service:  
1. Fungsionalitas C : 135140XX  
2. Fungsionalitas D : 135140XX  

Fitur security (IP, User-agent) :
1. Fungsionalitas E : 135140XX
2. Fungsionalitas F : 135140XX


## About

Asisten IF3110 2017

Ade | Johan | Kristianto | Micky | Michael | Rangga | Raudi | Robert | Sashi

Dosen : Yudistira Dwi Wardhana | Riza Satria Perdana | Muhammad Zuhri Catur Candra
