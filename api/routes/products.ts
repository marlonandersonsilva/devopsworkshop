import { Router, type Request, type Response } from 'express'
import { createClient } from '@supabase/supabase-js'

const router = Router()

const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_ANON_KEY
const supabaseKey = SUPABASE_SERVICE_ROLE_KEY || SUPABASE_ANON_KEY
const supabase = SUPABASE_URL && supabaseKey ? createClient(SUPABASE_URL, supabaseKey) : null

router.get('/', async (req: Request, res: Response): Promise<void> => {
  try {
    if (!supabase) {
      res.status(500).json({ success: false, error: 'Supabase não configurado' })
      return
    }

    const { category, search, limit = '24', offset = '0' } = req.query as Record<string, string>

    let query = supabase
      .from('produtos')
      .select('id_produto,nome,preco,categoria,status,produto_imagens(url_imagem,principal)')
      .order('created_at', { ascending: false })
      .range(parseInt(offset, 10), parseInt(offset, 10) + parseInt(limit, 10) - 1)

    if (category && category !== 'all') {
      query = query.eq('categoria', category)
    }

    if (search) {
      query = query.ilike('nome', `%${search}%`)
    }

    const { data, error } = await query
    if (error) {
      res.status(500).json({ success: false, error: error.message })
      return
    }

    const items = (data || []).map((p: any) => {
      const imgs = Array.isArray(p.produto_imagens) ? p.produto_imagens : []
      const principal = imgs.find((i: any) => i.principal) || imgs[0]
      return {
        id: p.id_produto,
        nome: p.nome,
        preco: p.preco,
        categoria: p.categoria,
        status: p.status,
        imagem: principal?.url_imagem || null,
      }
    })

    res.status(200).json({ success: true, items })
  } catch (e: any) {
    res.status(500).json({ success: false, error: 'Erro ao listar produtos' })
  }
})

router.get('/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    if (!supabase) {
      res.status(500).json({ success: false, error: 'Supabase não configurado' })
      return
    }
    const { id } = req.params
    const { data, error } = await supabase
      .from('produtos')
      .select('id_produto,nome,preco,categoria,status,descricao,sku,produto_imagens(url_imagem,principal)')
      .eq('id_produto', id)
      .single()
    if (error) {
      res.status(404).json({ success: false, error: 'Produto não encontrado' })
      return
    }
    const imgs = Array.isArray(data.produto_imagens) ? data.produto_imagens : []
    const principal = imgs.find((i: any) => i.principal) || imgs[0]
    res.status(200).json({ success: true, item: { ...data, imagem: principal?.url_imagem || null } })
  } catch (e: any) {
    res.status(500).json({ success: false, error: 'Erro ao buscar produto' })
  }
})

router.post('/', async (req: Request, res: Response): Promise<void> => {
  try {
    if (!supabase) {
      res.status(500).json({ success: false, error: 'Supabase não configurado' })
      return
    }
    const body = req.body || {}
    const required = ['nome', 'categoria', 'preco', 'sku']
    for (const f of required) {
      if (body[f] === undefined || body[f] === null || body[f] === '') {
        res.status(400).json({ success: false, error: `Campo obrigatório ausente: ${f}` })
        return
      }
    }
    const insert = {
      nome: body.nome,
      categoria: body.categoria,
      preco: body.preco,
      sku: body.sku,
      descricao: body.descricao ?? null,
      preco_promocional: body.preco_promocional ?? null,
      sustentavel: body.sustentavel ?? false,
      edicao_limitada: body.edicao_limitada ?? false,
      status: body.status ?? 'ativo',
    }
    const { data, error } = await supabase
      .from('produtos')
      .insert(insert)
      .select('id_produto')
      .single()
    if (error) {
      res.status(500).json({ success: false, error: error.message })
      return
    }
    res.status(201).json({ success: true, id: data.id_produto })
  } catch (e: any) {
    res.status(500).json({ success: false, error: 'Erro ao criar produto' })
  }
})

router.put('/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    if (!supabase) {
      res.status(500).json({ success: false, error: 'Supabase não configurado' })
      return
    }
    const { id } = req.params
    const body = req.body || {}
    const allowed = [
      'nome',
      'categoria',
      'preco',
      'sku',
      'descricao',
      'preco_promocional',
      'sustentavel',
      'edicao_limitada',
      'status',
    ]
    const update: Record<string, any> = {}
    for (const k of allowed) {
      if (k in body) update[k] = body[k]
    }
    if (Object.keys(update).length === 0) {
      res.status(400).json({ success: false, error: 'Nenhum campo para atualizar' })
      return
    }
    const { data, error } = await supabase
      .from('produtos')
      .update(update)
      .eq('id_produto', id)
      .select('id_produto')
      .single()
    if (error) {
      res.status(500).json({ success: false, error: error.message })
      return
    }
    res.status(200).json({ success: true, id: data.id_produto })
  } catch (e: any) {
    res.status(500).json({ success: false, error: 'Erro ao atualizar produto' })
  }
})

router.delete('/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    if (!supabase) {
      res.status(500).json({ success: false, error: 'Supabase não configurado' })
      return
    }
    const { id } = req.params
    const { data, error } = await supabase
      .from('produtos')
      .delete()
      .eq('id_produto', id)
      .select('id_produto')
      .single()
    if (error) {
      res.status(404).json({ success: false, error: 'Produto não encontrado' })
      return
    }
    res.status(200).json({ success: true, id: data.id_produto })
  } catch (e: any) {
    res.status(500).json({ success: false, error: 'Erro ao excluir produto' })
  }
})

export default router