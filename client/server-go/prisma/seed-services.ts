import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Sedang mengisi template jasa...');

  const services = [
    {
      title: 'Web Development',
      description: 'Pembuatan website profesional (Company Profile, Toko Online, Dashboard) dengan teknologi modern seperti Next.js, React, dan Tailwind CSS.',
      price: 'Mulai Rp 1.500.000',
      icon: 'Globe'
    },
    {
      title: 'Mobile App Development',
      description: 'Pengembangan aplikasi mobile Android & iOS kustom yang responsif, cepat, dan memiliki pengalaman pengguna terbaik.',
      price: 'Mulai Rp 5.000.000',
      icon: 'Smartphone'
    },
    {
      title: 'Backend System & API',
      description: 'Pembangunan arsitektur server yang aman, scalable, dan terintegrasi dengan database PostgreSQL atau MySQL.',
      price: 'Mulai Rp 2.000.000',
      icon: 'Database'
    },
    {
      title: 'WhatsApp Bot Integration',
      description: 'Integrasi chatbot WhatsApp otomatis untuk notifikasi OTP, customer service, atau sistem manajemen inventaris.',
      price: 'Mulai Rp 1.000.000',
      icon: 'MessageSquare'
    },
    {
      title: 'UI/UX Design',
      description: 'Desain tampilan antarmuka aplikasi yang modern, elegan, dan fokus pada kemudahan penggunaan bagi pelanggan Anda.',
      price: 'Mulai Rp 800.000',
      icon: 'Palette'
    },
    {
      title: 'SEO & Digital Marketing',
      description: 'Optimasi mesin pencari agar website Anda muncul di halaman pertama Google dan meningkatkan trafik pengunjung organik.',
      price: 'Mulai Rp 500.000',
      icon: 'Search'
    }
  ];

  // Hapus jasa lama (opsional, agar tidak duplikat)
  // await prisma.service.deleteMany();

  for (const service of services) {
    await prisma.service.upsert({
      where: { id: service.title.replace(/\s+/g, '-').toLowerCase() }, // Dummy ID dari title
      update: service,
      create: {
        id: service.title.replace(/\s+/g, '-').toLowerCase(),
        ...service
      }
    });
  }

  console.log('✅ Template jasa berhasil ditambahkan!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });