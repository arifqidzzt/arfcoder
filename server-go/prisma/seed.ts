import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const category = await prisma.category.upsert({
    where: { name: 'Software' },
    update: {},
    create: { name: 'Software' },
  });

  await prisma.product.createMany({
    data: [
      {
        name: 'ArfCoder E-Commerce Template',
        description: 'Template e-commerce siap pakai dengan desain minimalis.',
        price: 1500000,
        type: 'BARANG',
        stock: 100,
        categoryId: category.id,
        images: ['https://placehold.co/600x400/000000/FFFFFF?text=E-Commerce+Template'],
      },
      {
        name: 'Custom Web Development',
        description: 'Jasa pembuatan website kustom sesuai kebutuhan Anda.',
        price: 5000000,
        type: 'JASA',
        stock: 999,
        categoryId: category.id,
        images: ['https://placehold.co/600x400/000000/FFFFFF?text=Custom+Web'],
      },
    ],
  });

  console.log('Seeding finished.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
