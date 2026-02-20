# Vaccination System - Quick Start Guide

## Installation

### 1. Database Migration
Run the vaccination schema migration:
```bash
psql -U postgres -d petchain -f DATABASE_MIGRATION_VACCINATIONS.sql
```

### 2. Seed Default Schedules
```bash
# Seed dog vaccination schedules
curl -X POST http://localhost:3000/api/vaccination-schedules/seed/dogs

# Seed cat vaccination schedules
curl -X POST http://localhost:3000/api/vaccination-schedules/seed/cats
```

## Basic Operations

### Record a Vaccination

```bash
curl -X POST http://localhost:3000/api/vaccinations \
  -H "Content-Type: application/json" \
  -d '{
    "petId": "550e8400-e29b-41d4-a716-446655440000",
    "vaccineName": "Rabies",
    "manufacturer": "Merial",
    "batchNumber": "RV2024001234",
    "dateAdministered": "2024-12-01",
    "nextDueDate": "2025-12-01",
    "veterinarianName": "Dr. Sarah Johnson",
    "vetClinicId": "550e8400-e29b-41d4-a716-446655440001",
    "site": "Left front leg",
    "notes": "No adverse reactions observed"
  }'
```

Response:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440100",
  "petId": "550e8400-e29b-41d4-a716-446655440000",
  "vaccineName": "Rabies",
  "manufacturer": "Merial",
  "batchNumber": "RV2024001234",
  "dateAdministered": "2024-12-01T00:00:00.000Z",
  "nextDueDate": "2025-12-01T00:00:00.000Z",
  "certificateCode": "VAX-A1B2C3D4E5F6",
  "reminderSent": false,
  "createdAt": "2024-12-01T10:30:00.000Z",
  "updatedAt": "2024-12-01T10:30:00.000Z"
}
```

### Get Pet's Vaccination History

```bash
curl -X GET http://localhost:3000/api/vaccinations/pet/550e8400-e29b-41d4-a716-446655440000
```

### Generate Vaccination Certificate

```bash
curl -X POST http://localhost:3000/api/vaccinations/550e8400-e29b-41d4-a716-446655440100/certificate
```

Response:
```json
{
  "url": "/certificates/certificate-550e8400-e29b-41d4-a716-446655440100-1701421800000.pdf",
  "fileName": "certificate-550e8400-e29b-41d4-a716-446655440100-1701421800000.pdf"
}
```

### Download Certificate PDF

```bash
curl -X GET http://localhost:3000/api/vaccinations/550e8400-e29b-41d4-a716-446655440100/certificate/download \
  --output vaccination-certificate.pdf
```

### Log Adverse Reaction

```bash
curl -X POST http://localhost:3000/api/vaccinations/550e8400-e29b-41d4-a716-446655440100/reactions \
  -H "Content-Type: application/json" \
  -d '{
    "severity": "MILD",
    "description": "Slight swelling at injection site",
    "onsetHours": 2,
    "durationHours": 12,
    "treatment": "Applied cold compress",
    "requiredVeterinaryIntervention": false
  }'
```

### Check Vaccination Reminder Status

```bash
curl -X GET http://localhost:3000/api/vaccinations/550e8400-e29b-41d4-a716-446655440100/reminder-status
```

Response:
```json
{
  "status": "upcoming",
  "daysUntilDue": 15,
  "message": "Due in 15 days"
}
```

### Get Upcoming Reminders

```bash
# Get vaccinations due within 7 days
curl -X GET "http://localhost:3000/api/vaccinations/reminders/needing-reminders?days=7"
```

### Get Overdue Vaccinations

```bash
curl -X GET http://localhost:3000/api/vaccinations/overdue
```

### Send Vaccination Reminder

```bash
curl -X POST "http://localhost:3000/api/vaccinations/550e8400-e29b-41d4-a716-446655440100/send-reminder?userId=user-uuid"
```

### Get Pet Vaccination Statistics

```bash
curl -X GET http://localhost:3000/api/vaccinations/pet/550e8400-e29b-41d4-a716-446655440000/stats
```

Response:
```json
{
  "total": 5,
  "upToDate": 3,
  "overdue": 1,
  "upcoming": 1
}
```

## Vaccination Schedules

### Get Default Dog Schedules

```bash
curl -X GET http://localhost:3000/api/vaccination-schedules/general
```

### Get Breed-Specific Schedules

```bash
curl -X GET "http://localhost:3000/api/vaccination-schedules/breed/550e8400-e29b-41d4-a716-446655440050"
```

### Create Custom Schedule

```bash
curl -X POST http://localhost:3000/api/vaccination-schedules \
  -H "Content-Type: application/json" \
  -d '{
    "vaccineName": "Coronavirus",
    "description": "Recommended for show dogs",
    "recommendedAgeWeeks": 14,
    "intervalWeeks": 52,
    "dosesRequired": 1,
    "isRequired": false,
    "priority": 3
  }'
```

## Common Workflows

### Complete Vaccination Recording Workflow

```bash
# 1. Record the vaccination
VACC_ID=$(curl -s -X POST http://localhost:3000/api/vaccinations \
  -H "Content-Type: application/json" \
  -d '{
    "petId": "pet-uuid",
    "vaccineName": "DHPP",
    "manufacturer": "Merck",
    "batchNumber": "DHPP2024001",
    "dateAdministered": "2024-12-01",
    "nextDueDate": "2027-12-01",
    "veterinarianName": "Dr. Smith",
    "vetClinicId": "clinic-uuid"
  }' | jq -r '.id')

echo "Vaccination ID: $VACC_ID"

# 2. Generate certificate
curl -s -X POST http://localhost:3000/api/vaccinations/$VACC_ID/certificate | jq .

# 3. Check reminder status
curl -s -X GET http://localhost:3000/api/vaccinations/$VACC_ID/reminder-status | jq .

# 4. Mark pet as up-to-date
curl -s -X GET http://localhost:3000/api/vaccinations/pet/pet-uuid/stats | jq .
```

### Process Reminders Workflow

```bash
# 1. Get vaccinations needing reminders (next 7 days)
curl -s -X GET "http://localhost:3000/api/vaccinations/reminders/needing-reminders?days=7" | jq .

# 2. Send batch reminders
curl -s -X POST "http://localhost:3000/api/vaccinations/reminders/send-batch?days=7&userId=user-uuid" | jq .

# 3. Verify reminder status
curl -s -X GET http://localhost:3000/api/vaccinations/overdue | jq .
```

### Adverse Reaction Tracking

```bash
# 1. Log reaction
REACTION=$(curl -s -X POST http://localhost:3000/api/vaccinations/$VACC_ID/reactions \
  -H "Content-Type: application/json" \
  -d '{
    "severity": "MODERATE",
    "description": "Fever and lethargy"
  }' | jq -r '.id')

# 2. View all reactions
curl -s -X GET http://localhost:3000/api/vaccinations/$VACC_ID/reactions | jq .

# 3. Report to manufacturer
curl -s -X PATCH http://localhost:3000/api/vaccinations/reactions/$REACTION \
  -H "Content-Type: application/json" \
  -d '{
    "reportedToManufacturer": true,
    "manufacturerReportId": "MFR-2024-001"
  }' | jq .
```

## Integration with Pet Management

The vaccination system integrates with the pet management system:

```bash
# Get pet details with vaccinations
curl -s -X GET http://localhost:3000/api/pets/pet-uuid | jq .

# The response includes:
# {
#   "id": "pet-uuid",
#   "name": "Max",
#   "breed": "Golden Retriever",
#   "vaccinations": [
#     { "id": "vacc-1", "vaccineName": "Rabies", ... },
#     { "id": "vacc-2", "vaccineName": "DHPP", ... }
#   ]
# }
```

## Frontend Integration Examples

### Vue.js Component Example

```vue
<template>
  <div class="vaccination-tracker">
    <h2>{{ pet.name }} Vaccinations</h2>
    
    <div v-if="stats" class="stats">
      <p>Total: {{ stats.total }}</p>
      <p>Up to Date: {{ stats.upToDate }}</p>
      <p>Overdue: {{ stats.overdue }}</p>
      <p>Upcoming: {{ stats.upcoming }}</p>
    </div>

    <button @click="fetchVaccinations">Load Vaccinations</button>
    
    <div v-for="vaccination in vaccinations" :key="vaccination.id">
      <h3>{{ vaccination.vaccineName }}</h3>
      <p>Administered: {{ formatDate(vaccination.dateAdministered) }}</p>
      <p>Next Due: {{ formatDate(vaccination.nextDueDate) }}</p>
      <button @click="downloadCertificate(vaccination.id)">Download Certificate</button>
      <button @click="sendReminder(vaccination.id)">Send Reminder</button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      vaccinations: [],
      stats: null
    }
  },
  props: {
    petId: String
  },
  methods: {
    async fetchVaccinations() {
      const response = await fetch(`/api/vaccinations/pet/${this.petId}`);
      this.vaccinations = await response.json();
      
      const statsResponse = await fetch(`/api/vaccinations/pet/${this.petId}/stats`);
      this.stats = await statsResponse.json();
    },
    async downloadCertificate(vaccinationId) {
      window.location.href = `/api/vaccinations/${vaccinationId}/certificate/download`;
    },
    async sendReminder(vaccinationId) {
      const response = await fetch(
        `/api/vaccinations/${vaccinationId}/send-reminder?userId=${this.userId}`,
        { method: 'POST' }
      );
      const result = await response.json();
      alert(`Reminder ${result.success ? 'sent' : 'failed'}`);
    }
  }
}
</script>
```

## Troubleshooting

### Certificate Not Generating
- Ensure the `/certificates` directory exists and is writable
- Check PDFKit is properly installed
- Verify vaccination record has all required fields

### Reminders Not Sending
- Check NotificationService integration
- Verify user notification preferences
- Check reminder status hasn't already been sent

### Dates Not Calculating Correctly
- Ensure timezone is set correctly
- Verify dateAdministered is in YYYY-MM-DD format
- Check vaccination schedule has intervalWeeks set

## Performance Optimization

### Database Indexes
The migration script creates indexes on:
- `petId` - For quick pet lookups
- `nextDueDate` - For reminder queries
- `reminderSent` - For pending reminders
- `certificateCode` - For unique code lookups

### API Response Pagination
For large datasets, consider adding pagination:

```bash
curl -X GET "http://localhost:3000/api/vaccinations?page=1&limit=50"
```

## Next Steps

1. **Configure Notifications**: Set up email/SMS notification templates
2. **Integrate Blockchain**: Link vaccination records to blockchain ledger
3. **Create Dashboard**: Build admin dashboard for vaccination oversight
4. **Setup Reminders**: Configure scheduled reminder batches
5. **Add Mobile Support**: Build mobile app for easy certificate access

## Additional Resources

- [Full API Documentation](./VACCINATIONS_DOCUMENTATION.md)
- [Database Schema](./DATABASE_MIGRATION_VACCINATIONS.sql)
- [Architecture Overview](./IMPLEMENTATION_SUMMARY.md)
