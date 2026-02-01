import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const email = 'admin@arfcoder.com';
  const password = 'admin123'; // Password sementara
  const name = 'Super Admin';

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await prisma.user.upsert({
    where: { email },
    update: {
      role: 'SUPER_ADMIN',
      isVerified: true,
    },
    create: {
      email,
      password: hashedPassword,
      name,
      role: 'SUPER_ADMIN',
      isVerified: true,
    },
  });

  console.log(`
  ✅ Admin Created Successfully!
  ---------------------------
  Email: ${email}
  Pass : ${password}
  Role : ${user.role}
  ---------------------------
  Silakan login di http://localhost:3000/login
  `);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
