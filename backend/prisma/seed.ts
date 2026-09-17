// prisma/seed.ts
import { PrismaClient, PerfilUsuario, TipoSenha, StatusSenha } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed...');

  // ─── Filiais ─────────────────────────────────────────────
  const filialSP = await prisma.filial.create({
    data: { nome: 'Filial São Paulo Centro', cidade: 'São Paulo', estado: 'SP' },
  });
  const filialRJ = await prisma.filial.create({
    data: { nome: 'Filial Rio de Janeiro', cidade: 'Rio de Janeiro', estado: 'RJ' },
  });

  // ─── Departamentos ────────────────────────────────────────
  const deptoRH_SP = await prisma.departamento.create({
    data: { filialId: filialSP.id, nome: 'Recursos Humanos' },
  });
  const deptoFin_SP = await prisma.departamento.create({
    data: { filialId: filialSP.id, nome: 'Financeiro' },
  });
  const deptoAtend_SP = await prisma.departamento.create({
    data: { filialId: filialSP.id, nome: 'Atendimento ao Cliente' },
  });
  const deptoRH_RJ = await prisma.departamento.create({
    data: { filialId: filialRJ.id, nome: 'Recursos Humanos' },
  });

  // ─── Setores ─────────────────────────────────────────────
  const setorAdmissao = await prisma.setor.create({
    data: { departamentoId: deptoRH_SP.id, nome: 'Admissão e Cadastro', sigla: 'ADM' },
  });
  const setorBeneficios = await prisma.setor.create({
    data: { departamentoId: deptoRH_SP.id, nome: 'Benefícios', sigla: 'BEN' },
  });
  const setorCaixa = await prisma.setor.create({
    data: { departamentoId: deptoFin_SP.id, nome: 'Caixa e Pagamentos', sigla: 'CAI' },
  });
  const setorCredito = await prisma.setor.create({
    data: { departamentoId: deptoFin_SP.id, nome: 'Crédito e Análise', sigla: 'CRE' },
  });
  const setorSAC = await prisma.setor.create({
    data: { departamentoId: deptoAtend_SP.id, nome: 'SAC Geral', sigla: 'SAC' },
  });
  const setorRH_RJ = await prisma.setor.create({
    data: { departamentoId: deptoRH_RJ.id, nome: 'Admissão RJ', sigla: 'ARJ' },
  });

  // ─── Mesas ───────────────────────────────────────────────
  const mesasCaixa: any[] = [];
  for (let i = 1; i <= 4; i++) {
    const m = await prisma.mesa.create({
      data: { setorId: setorCaixa.id, numeroIdentificador: `0${i}` },
    });
    mesasCaixa.push(m);
  }
  const mesasAdm: any[] = [];
  for (let i = 1; i <= 3; i++) {
    const m = await prisma.mesa.create({
      data: { setorId: setorAdmissao.id, numeroIdentificador: `0${i}` },
    });
    mesasAdm.push(m);
  }
  const mesasBen: any[] = [];
  for (let i = 1; i <= 2; i++) {
    const m = await prisma.mesa.create({
      data: { setorId: setorBeneficios.id, numeroIdentificador: `0${i}` },
    });
    mesasBen.push(m);
  }
  const mesasSAC: any[] = [];
  for (let i = 1; i <= 3; i++) {
    const m = await prisma.mesa.create({
      data: { setorId: setorSAC.id, numeroIdentificador: `0${i}` },
    });
    mesasSAC.push(m);
  }

  // ─── Usuários ─────────────────────────────────────────────
  const hash = (p: string) => bcrypt.hashSync(p, 10);

  // ADMIN global
  await prisma.usuario.create({
    data: {
      filialId: filialSP.id,
      nome: 'Administrador Sistema',
      email: 'admin@fila.com',
      senhaHash: hash('admin123'),
      perfil: PerfilUsuario.ADMIN,
    },
  });

  // Gerentes
  const gerenteSP = await prisma.usuario.create({
    data: {
      filialId: filialSP.id,
      setorId: setorCaixa.id,
      nome: 'Carlos Mendes',
      email: 'gerente.sp@fila.com',
      senhaHash: hash('gerente123'),
      perfil: PerfilUsuario.GERENTE,
    },
  });

  // Atendentes de Triagem
  const triagem1 = await prisma.usuario.create({
    data: {
      filialId: filialSP.id,
      setorId: setorAdmissao.id,
      nome: 'Ana Beatriz (Triagem)',
      email: 'triagem1@fila.com',
      senhaHash: hash('triagem123'),
      perfil: PerfilUsuario.TRIAGEM,
    },
  });

  // Atendentes - Caixa
  const atenCaixa1 = await prisma.usuario.create({
    data: {
      filialId: filialSP.id,
      setorId: setorCaixa.id,
      nome: 'Ricardo Oliveira',
      email: 'atendente.caixa1@fila.com',
      senhaHash: hash('atendente123'),
      perfil: PerfilUsuario.ATENDENTE,
    },
  });
  const atenCaixa2 = await prisma.usuario.create({
    data: {
      filialId: filialSP.id,
      setorId: setorCaixa.id,
      nome: 'Fernanda Lima',
      email: 'atendente.caixa2@fila.com',
      senhaHash: hash('atendente123'),
      perfil: PerfilUsuario.ATENDENTE,
    },
  });

  // Atendentes - Admissão
  const atenAdm1 = await prisma.usuario.create({
    data: {
      filialId: filialSP.id,
      setorId: setorAdmissao.id,
      nome: 'Mariana Costa',
      email: 'atendente.adm1@fila.com',
      senhaHash: hash('atendente123'),
      perfil: PerfilUsuario.ATENDENTE,
    },
  });

  // Atendentes - SAC
  const atenSAC1 = await prisma.usuario.create({
    data: {
      filialId: filialSP.id,
      setorId: setorSAC.id,
      nome: 'Paulo Souza',
      email: 'atendente.sac1@fila.com',
      senhaHash: hash('atendente123'),
      perfil: PerfilUsuario.ATENDENTE,
    },
  });

  // ─── Senhas (dados históricos para relatórios) ────────────
  const hoje = new Date();
  const ontem = new Date(hoje);
  ontem.setDate(ontem.getDate() - 1);

  // Contador
  const getContador = async (setorId: string, data: Date) => {
    const dateOnly = new Date(data.toISOString().split('T')[0]);
    const c = await prisma.contadorFila.upsert({
      where: { setorId_data: { setorId, data: dateOnly } },
      update: { ultimoNumero: { increment: 1 } },
      create: { setorId, data: dateOnly, ultimoNumero: 1 },
    });
    return c.ultimoNumero;
  };

  const criarSenhaFinalizada = async (
    setorId: string,
    filialId: string,
    triagemId: string,
    atendenteId: string,
    mesaId: string,
    sigla: string,
    tipo: TipoSenha,
    data: Date,
    esperaSeg: number,
    atendSeg: number,
  ) => {
    const num = await getContador(setorId, data);
    const chamadaEm = new Date(data.getTime() + esperaSeg * 1000);
    const inicioEm = new Date(chamadaEm.getTime() + 15000);
    const fimEm = new Date(inicioEm.getTime() + atendSeg * 1000);
    const senha = await prisma.senha.create({
      data: {
        filialId,
        setorId,
        usuarioTriagemId: triagemId,
        codigo: `${sigla}-${String(num).padStart(3, '0')}`,
        numeroSequencial: num,
        tipo,
        status: StatusSenha.FINALIZADA,
        criadaEm: data,
        chamadaEm,
        atendimentoInicioEm: inicioEm,
        finalizadaEm: fimEm,
        tempoEsperaSegundos: esperaSeg,
        tempoAtendimentoSegundos: atendSeg,
      },
    });
    await prisma.atendimento.create({
      data: {
        senhaId: senha.id,
        atendenteId,
        mesaId,
        iniciadoEm: inicioEm,
        finalizadoEm: fimEm,
      },
    });
    return senha;
  };

  // Histórico ontem - Caixa
  for (let i = 0; i < 12; i++) {
    const base = new Date(ontem);
    base.setHours(8 + Math.floor(i / 3), i * 5, 0, 0);
    const atend = i % 2 === 0 ? atenCaixa1 : atenCaixa2;
    const mesa = i % 2 === 0 ? mesasCaixa[0] : mesasCaixa[1];
    await criarSenhaFinalizada(
      setorCaixa.id, filialSP.id, triagem1.id, atend.id, mesa.id,
      'CAI', i % 5 === 0 ? TipoSenha.PREFERENCIAL : TipoSenha.NORMAL,
      base, 120 + i * 30, 180 + i * 20,
    );
  }

  // Histórico ontem - Admissão
  for (let i = 0; i < 8; i++) {
    const base = new Date(ontem);
    base.setHours(9 + Math.floor(i / 2), i * 7, 0, 0);
    await criarSenhaFinalizada(
      setorAdmissao.id, filialSP.id, triagem1.id, atenAdm1.id, mesasAdm[0].id,
      'ADM', i % 4 === 0 ? TipoSenha.PREFERENCIAL : TipoSenha.NORMAL,
      base, 90 + i * 25, 240 + i * 15,
    );
  }

  // Histórico hoje - Caixa (manhã)
  for (let i = 0; i < 6; i++) {
    const base = new Date(hoje);
    base.setHours(8, 15 * i, 0, 0);
    const atend = i % 2 === 0 ? atenCaixa1 : atenCaixa2;
    const mesa = i % 2 === 0 ? mesasCaixa[0] : mesasCaixa[1];
    await criarSenhaFinalizada(
      setorCaixa.id, filialSP.id, triagem1.id, atend.id, mesa.id,
      'CAI', i % 3 === 0 ? TipoSenha.PREFERENCIAL : TipoSenha.NORMAL,
      base, 60 + i * 20, 150 + i * 25,
    );
  }

  // Senhas AGUARDANDO (fila atual) - Caixa
  const now = new Date();
  for (let i = 0; i < 5; i++) {
    const num = await getContador(setorCaixa.id, now);
    const criada = new Date(now.getTime() - (5 - i) * 3 * 60 * 1000);
    await prisma.senha.create({
      data: {
        filialId: filialSP.id,
        setorId: setorCaixa.id,
        usuarioTriagemId: triagem1.id,
        codigo: `CAI-${String(num).padStart(3, '0')}`,
        numeroSequencial: num,
        tipo: i === 1 ? TipoSenha.PREFERENCIAL : TipoSenha.NORMAL,
        status: StatusSenha.AGUARDANDO,
        criadaEm: criada,
      },
    });
  }

  // Senhas AGUARDANDO - Admissão
  for (let i = 0; i < 3; i++) {
    const num = await getContador(setorAdmissao.id, now);
    const criada = new Date(now.getTime() - (3 - i) * 4 * 60 * 1000);
    await prisma.senha.create({
      data: {
        filialId: filialSP.id,
        setorId: setorAdmissao.id,
        usuarioTriagemId: triagem1.id,
        codigo: `ADM-${String(num).padStart(3, '0')}`,
        numeroSequencial: num,
        tipo: i === 0 ? TipoSenha.PREFERENCIAL : TipoSenha.NORMAL,
        status: StatusSenha.AGUARDANDO,
        criadaEm: criada,
      },
    });
  }

  // Senhas AGUARDANDO - SAC
  for (let i = 0; i < 4; i++) {
    const num = await getContador(setorSAC.id, now);
    const criada = new Date(now.getTime() - (4 - i) * 2 * 60 * 1000);
    await prisma.senha.create({
      data: {
        filialId: filialSP.id,
        setorId: setorSAC.id,
        usuarioTriagemId: triagem1.id,
        codigo: `SAC-${String(num).padStart(3, '0')}`,
        numeroSequencial: num,
        tipo: TipoSenha.NORMAL,
        status: StatusSenha.AGUARDANDO,
        criadaEm: criada,
      },
    });
  }

  console.log('✅ Seed concluído!');
  console.log('');
  console.log('👤 Usuários criados:');
  console.log('  admin@fila.com        | senha: admin123      | ADMIN');
  console.log('  gerente.sp@fila.com   | senha: gerente123    | GERENTE');
  console.log('  triagem1@fila.com     | senha: triagem123    | TRIAGEM');
  console.log('  atendente.caixa1@fila.com | senha: atendente123 | ATENDENTE (Caixa)');
  console.log('  atendente.caixa2@fila.com | senha: atendente123 | ATENDENTE (Caixa)');
  console.log('  atendente.adm1@fila.com   | senha: atendente123 | ATENDENTE (Admissão)');
  console.log('  atendente.sac1@fila.com   | senha: atendente123 | ATENDENTE (SAC)');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
