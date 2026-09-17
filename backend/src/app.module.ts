// src/app.module.ts
import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { PrismaService } from './prisma.service';
import { AuthModule } from './auth/auth.module';
import { QueueModule } from './queue/queue.module';
import { FiliaisController } from './filiais/filiais.controller';
import { RelatoriosController } from './relatorios/relatorios.controller';
import { PainelController } from './painel/painel.controller';

@Module({
  imports: [AuthModule, QueueModule],
  controllers: [FiliaisController, RelatoriosController, PainelController],
  providers: [PrismaService],
})
export class AppModule {}
