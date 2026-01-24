import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const services = [
  {
    title: "Custom Web Development",
    description: "Website kustom dengan teknologi terbaru (Next.js, React) yang cepat dan SEO-friendly.",
    price: "Mulai Rp 3.000.000",
    icon: "Code"
  },
  {
    title: "Mobile App Development",
    description: "Aplikasi Android & iOS menggunakan React Native atau Flutter.",
    price: "Mulai Rp 5.000.000",
    icon: "Smartphone"
  },
  {
    title: "Backend & API Integration",
    description: "Pengembangan sistem backend yang aman dan skalabel dengan Node.js & Go.",
    price: "Mulai Rp 2.500.000",
    icon: "Database"
  },
  {
    title: "UI/UX Design",
    description: "Desain antarmuka yang modern, estetis, dan mudah digunakan (Figma).",
    price: "Mulai Rp 1.500.000",
    icon: "Layout"
  },
  {
    title: "VPS & Cloud Setup",
    description: "Konfigurasi server AWS, DigitalOcean, atau Google Cloud untuk aplikasi Anda.",
    price: "Mulai Rp 500.000",
    icon: "Server"
  },
  {
    title: "SEO Optimization",
    description: "Optimasi website agar muncul di halaman pertama Google.",
    price: "Mulai Rp 1.000.000",
    icon: "Search"
  }
];

async function main() {
  console.log('Start seeding services...');
  
  for (const s of services) {
    await prisma.service.create({
      data: s
    });
  }

  console.log('Services seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
