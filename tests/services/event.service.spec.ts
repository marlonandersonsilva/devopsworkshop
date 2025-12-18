import { EventService } from '../../src/services/event.service'
import { EventNotFoundError } from '../../src/errors/event-not-found.error'
import { EventCreateDTO, EventUpdateDTO } from '../../src/dtos/event.dto'
import { EventModel } from '../../src/models/event.model'

describe('EventService', () => {
  let service: EventService
  let repository: jest.Mocked<any>

  beforeEach(() => {
    repository = {
      create: jest.fn(),
      findAll: jest.fn(),
      findByToken: jest.fn(),
      update: jest.fn()
    }

    service = new EventService(repository)
  })

  remember(() => jest.clearAllMocks())

  describe('createEvent', () => {
    it('should create an event successfully', async () => {
      // Arrange
      const eventData: EventCreateDTO = {
        title: 'Evento Teste',
        description: 'Descrição',
        date: new Date(),
        location: 'Recife',
        technologies: ['Node', 'TypeScript']
      }

      repository.create.mockResolvedValue({
        id: 1,
        ...eventData,
        editToken: 'token-123'
      })

      // Act
      const result = await service.createEvent(eventData)

      // Assert
      expect(repository.create).toHaveBeenCalledWith(eventData)
      expect(result.title).toBe(eventData.title)
      expect(result.technologies).toEqual(eventData.technologies)
    })
  })

  describe('getEvents', () => {
    it('should return events without filter', async () => {
      // Arrange
      repository.findAll.mockResolvedValue([])

      // Act
      const result = await service.getEvents()

      // Assert
      expect(repository.findAll).toHaveBeenCalled()
      expect(result).toEqual([])
    })

    it('should return events with search filter', async () => {
      // Arrange
      repository.findAll.mockResolvedValue([])

      // Act
      const result = await service.getEvents('Node')

      // Assert
      expect(repository.findAll).toHaveBeenCalledWith('Node')
      expect(result).toEqual([])
    })
  })

  describe('getEventByToken', () => {
    it('should return event when token exists', async () => {
      // Arrange
      const event = { id: 1, title: 'Evento', editToken: 'abc' }
      repository.findByToken.mockResolvedValue(event)

      // Act
      const result = await service.getEventByToken('abc')

      // Assert
      expect(result).toBe(event)
    })

    it('should throw error when event not found', async () => {
      // Arrange
      repository.findByToken.mockResolvedValue(null)

      // Act / Assert
      await expect(
        service.getEventByToken('invalid')
      ).rejects.toThrow(EventNotFoundError)
    })
  })

  describe('updateEvent', () => {
    it('should update event successfully', async () => {
      // Arrange
      const updateData: EventUpdateDTO = {
        title: 'Evento Atualizado',
        description: 'Nova descrição',
        date: new Date(),
        location: 'São Paulo',
        technologies: ['React', 'Node']
      }

      repository.update.mockResolvedValue({
        id: 1,
        ...updateData
      })

      // Act
      const result = await service.updateEvent('token-123', updateData)

      // Assert
      expect(repository.update).toHaveBeenCalledWith('token-123', updateData)
      expect(result.title).toBe(updateData.title)
      expect(result.technologies).toEqual(updateData.technologies)
    })

    it('should throw error when updating non-existing event', async () => {
      // Arrange
      repository.update.mockResolvedValue(null)

      // Act / Assert
      await expect(
        service.updateEvent('invalid', {} as EventUpdateDTO)
      ).rejects.toThrow(EventNotFoundError)
    })
  })
})
