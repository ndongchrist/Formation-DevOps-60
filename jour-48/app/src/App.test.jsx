import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'
import App from './App'

beforeEach(() => {
  localStorage.clear()
})

describe('My DevOps Tasks', () => {
  it('affiche un message quand la liste est vide', () => {
    render(<App />)
    expect(screen.getByText(/Aucune tâche pour l’instant/)).toBeInTheDocument()
  })

  it('ajoute une tâche', async () => {
    const user = userEvent.setup()
    render(<App />)

    await user.type(screen.getByLabelText('Nouvelle tâche'), 'Configurer Jenkins')
    await user.click(screen.getByRole('button', { name: 'Ajouter' }))

    expect(screen.getByText('Configurer Jenkins')).toBeInTheDocument()
    expect(screen.getByText('1 tâche à faire')).toBeInTheDocument()
  })

  it('refuse une tâche vide', async () => {
    const user = userEvent.setup()
    render(<App />)

    await user.click(screen.getByRole('button', { name: 'Ajouter' }))

    expect(screen.getByRole('alert')).toHaveTextContent('Écris une tâche')
  })

  it('termine une tâche et la cache dans le filtre « À faire »', async () => {
    const user = userEvent.setup()
    render(<App />)

    await user.type(screen.getByLabelText('Nouvelle tâche'), 'Écrire le Jenkinsfile{Enter}')
    await user.click(screen.getByRole('checkbox'))
    expect(screen.getByText('Rien à faire, profite !')).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'À faire' }))
    expect(screen.queryByText('Écrire le Jenkinsfile')).not.toBeInTheDocument()
  })

  it('supprime une tâche', async () => {
    const user = userEvent.setup()
    render(<App />)

    await user.type(screen.getByLabelText('Nouvelle tâche'), 'Tâche à supprimer{Enter}')
    await user.click(screen.getByRole('button', { name: /Supprimer/ }))

    expect(screen.queryByText('Tâche à supprimer')).not.toBeInTheDocument()
  })
})