# Vaccination Management System Documentation

## Overview

The PetChain Vaccination Management System provides comprehensive tracking and management of pet vaccinations, including automated reminder generation, PDF certificate generation, adverse reaction logging, and breed-based vaccination schedules.

## Features

### 1. **Record Vaccinations**
- Track all vaccinations administered to pets
- Record vaccine name, manufacturer, batch number
- Track administration date and veterinarian details
- Associate vaccinations with vet clinics
- Add injection site and notes

### 2. **Vaccination Schedules by Breed**
- Pre-configured vaccination schedules for common dog and cat breeds
- Breed-specific vaccination recommendations
- General vaccination schedules (non-breed-specific)
- Priority-based scheduling
- Core vs. non-core vaccine differentiation

### 3. **Next Due Date Calculation**
- Automatic next due date calculation based on vaccination schedule
- Support for one-time and recurring vaccinations
- Configurable intervals (e.g., annual, every 3 years)
- Overdue vaccination detection

### 4. **Vaccination Certificates**
- Generate official PDF vaccination certificates
- Unique certificate codes for verification
- Professional certificate design with all vaccination details
- Certificate storage and retrieval
- Certificate code lookup

### 5. **Batch Number Tracking**
- Complete batch number recording for every vaccination
- Batch expiration date tracking
- Support for vaccine recalls
- Manufacturing information storage

### 6. **Adverse Reaction Logging**
- Log and track adverse reactions to vaccines
- Severity classification (MILD, MODERATE, SEVERE)
- Onset and duration tracking
- Treatment documentation
- Manufacturer reporting capability
- HIPAA-compliant adverse event recording

## Database Schema

### Vaccinations Table
```sql
CREATE TABLE vaccinations (
    id UUID PRIMARY KEY,
    petId UUID NOT NULL,
    vaccineName VARCHAR(255) NOT NULL,
    manufacturer VARCHAR(255),
    batchNumber VARCHAR(255),
    dateAdministered DATE NOT NULL,
    nextDueDate DATE,
    expirationDate DATE,
    site VARCHAR(255),
    veterinarianName VARCHAR(255) NOT NULL,
    vetClinicId UUID,
    certificateUrl VARCHAR(500),
    certificateCode VARCHAR(50) UNIQUE,
    reminderSent BOOLEAN DEFAULT false,
    notes TEXT,
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP
);
```

### Vaccination Reactions Table
```sql
CREATE TABLE vaccination_reactions (
    id UUID PRIMARY KEY,
    vaccinationId UUID NOT NULL,
    severity ENUM('MILD', 'MODERATE', 'SEVERE'),
    description TEXT NOT NULL,
    onsetHours INTEGER,
    durationHours INTEGER,
    treatment TEXT,
    requiredVeterinaryIntervention BOOLEAN,
    notes TEXT,
    reportedToManufacturer BOOLEAN,
    manufacturerReportId VARCHAR(255),
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP
);
```

### Vaccination Schedules Table
```sql
CREATE TABLE vaccination_schedules (
    id UUID PRIMARY KEY,
    breedId UUID,
    vaccineName VARCHAR(255) NOT NULL,
    description TEXT,
    recommendedAgeWeeks INTEGER NOT NULL,
    intervalWeeks INTEGER,
    dosesRequired INTEGER,
    isRequired BOOLEAN,
    isActive BOOLEAN,
    priority INTEGER,
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP
);
```

## API Endpoints

### Vaccination Management

#### Create Vaccination
```
POST /vaccinations
Content-Type: application/json

{
    "petId": "uuid",
    "vaccineName": "Rabies",
    "manufacturer": "Merial",
    "batchNumber": "2024001234",
    "dateAdministered": "2024-12-01",
    "nextDueDate": "2025-12-01",
    "expirationDate": "2025-12-01",
    "veterinarianName": "Dr. Smith",
    "vetClinicId": "uuid",
    "site": "Left front leg",
    "notes": "No adverse reactions"
}
```

#### Get All Vaccinations
```
GET /vaccinations
```

#### Get Vaccinations by Pet
```
GET /vaccinations/pet/:petId
```

#### Get Vaccination Statistics
```
GET /vaccinations/pet/:petId/stats

Response:
{
    "total": 5,
    "upToDate": 3,
    "overdue": 1,
    "upcoming": 1
}
```

#### Get Vaccination Details
```
GET /vaccinations/:id
```

#### Update Vaccination
```
PATCH /vaccinations/:id
Content-Type: application/json

{
    "notes": "Updated notes"
}
```

#### Delete Vaccination
```
DELETE /vaccinations/:id
```

### Reminder Management

#### Get Upcoming Reminders
```
GET /vaccinations/reminders?days=30
```

#### Get Overdue Vaccinations
```
GET /vaccinations/overdue?petId=xxx
```

#### Get Vaccination Needing Reminders
```
GET /vaccinations/reminders/needing-reminders?days=7
```

#### Get Reminder Status
```
GET /vaccinations/:id/reminder-status

Response:
{
    "status": "upcoming",
    "daysUntilDue": 15,
    "message": "Due in 15 days"
}
```

#### Send Reminder
```
POST /vaccinations/:id/send-reminder?userId=xxx

Response:
{
    "success": true,
    "message": "Reminder sent successfully"
}
```

#### Send Batch Reminders
```
POST /vaccinations/reminders/send-batch?days=7&userId=xxx

Response:
{
    "sent": 10,
    "failed": 1,
    "details": [...]
}
```

#### Mark Reminder as Sent
```
PATCH /vaccinations/:id/reminder-sent
```

#### Process Pet Reminders
```
POST /vaccinations/pet/:petId/process-reminders
```

### Certificate Management

#### Generate Certificate
```
POST /vaccinations/:id/certificate

Response:
{
    "url": "/certificates/certificate-uuid-timestamp.pdf",
    "fileName": "certificate-uuid-timestamp.pdf"
}
```

#### Download Certificate
```
GET /vaccinations/:id/certificate/download
```

#### Get Certificate File
```
GET /vaccinations/certificate-file/:fileName
```

#### Find by Certificate Code
```
GET /vaccinations/certificate/:code
```

### Adverse Reaction Management

#### Add Reaction
```
POST /vaccinations/:id/reactions
Content-Type: application/json

{
    "severity": "MODERATE",
    "description": "Swelling at injection site",
    "onsetHours": 2,
    "durationHours": 24,
    "treatment": "Cold compress applied",
    "requiredVeterinaryIntervention": false,
    "notes": "Resolved within 24 hours"
}
```

#### Get Reactions
```
GET /vaccinations/:id/reactions
```

#### Update Reaction
```
PATCH /vaccinations/reactions/:reactionId
Content-Type: application/json

{
    "reportedToManufacturer": true,
    "manufacturerReportId": "REP-2024-001234"
}
```

#### Delete Reaction
```
DELETE /vaccinations/reactions/:reactionId
```

### Vaccination Schedules

#### Get All Schedules
```
GET /vaccination-schedules
```

#### Get Breed-Specific Schedules
```
GET /vaccination-schedules/breed/:breedId
```

#### Get General Schedules
```
GET /vaccination-schedules/general
```

#### Create Schedule
```
POST /vaccination-schedules
Content-Type: application/json

{
    "breedId": "optional-uuid",
    "vaccineName": "DHPP",
    "description": "Core combination vaccine",
    "recommendedAgeWeeks": 6,
    "intervalWeeks": 156,
    "dosesRequired": 3,
    "isRequired": true,
    "priority": 9
}
```

#### Get Schedule Details
```
GET /vaccination-schedules/:id
```

#### Update Schedule
```
PATCH /vaccination-schedules/:id
```

#### Delete Schedule
```
DELETE /vaccination-schedules/:id
```

#### Seed Default Schedules
```
POST /vaccination-schedules/seed/dogs
POST /vaccination-schedules/seed/cats
```

## Default Vaccination Schedules

### Dogs (DHPP Core Vaccines)

1. **DHPP (Distemper, Hepatitis, Parvovirus, Parainfluenza)**
   - Age: 6 weeks
   - Interval: Every 3 years (after initial series)
   - Doses: 3
   - Required: Yes
   - Priority: 9

2. **Rabies**
   - Age: 12 weeks
   - Interval: Annual
   - Doses: 1
   - Required: Yes (by law)
   - Priority: 10

3. **Bordetella (Kennel Cough)**
   - Age: 8 weeks
   - Interval: Annual
   - Doses: 1
   - Required: No
   - Priority: 7

4. **Leptospirosis**
   - Age: 12 weeks
   - Interval: Annual
   - Doses: 2
   - Required: No
   - Priority: 6

5. **Lyme Disease**
   - Age: 12 weeks
   - Interval: Annual
   - Doses: 2
   - Required: No
   - Priority: 5

### Cats (FVRCP Core Vaccines)

1. **FVRCP (Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia)**
   - Age: 6 weeks
   - Interval: Every 3 years
   - Doses: 3
   - Required: Yes
   - Priority: 9

2. **Rabies**
   - Age: 12 weeks
   - Interval: Annual
   - Doses: 1
   - Required: Yes
   - Priority: 10

3. **FeLV (Feline Leukemia Virus)**
   - Age: 8 weeks
   - Interval: Annual
   - Doses: 2
   - Required: No (for outdoor cats)
   - Priority: 7

## Integration Points

### Notification Service Integration
The system is designed to integrate with the PetChain Notification Service for:
- Email notifications
- SMS alerts
- Push notifications
- In-app notifications

### Storage Integration
Certificate PDFs can be stored in:
- Local filesystem (development)
- AWS S3 (production)
- Google Cloud Storage

### Blockchain Integration
Vaccination records can be optionally recorded on the Stellar blockchain for:
- Immutable audit trail
- Cross-clinic verification
- Pet health history verification

## Usage Examples

### Create and Manage a Vaccination

```javascript
// Create vaccination
const vaccination = await fetch('/api/vaccinations', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        petId: 'pet-uuid',
        vaccineName: 'Rabies',
        manufacturer: 'Merial',
        batchNumber: '2024001234',
        dateAdministered: '2024-12-01',
        veterinarianName: 'Dr. Smith',
        vetClinicId: 'clinic-uuid'
    })
}).then(r => r.json());

// Generate certificate
const cert = await fetch(`/api/vaccinations/${vaccination.id}/certificate`, {
    method: 'POST'
}).then(r => r.json());

// Log adverse reaction if needed
const reaction = await fetch(`/api/vaccinations/${vaccination.id}/reactions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        severity: 'MILD',
        description: 'Slight lethargy for 2 hours'
    })
}).then(r => r.json());

// Check reminder status
const status = await fetch(`/api/vaccinations/${vaccination.id}/reminder-status`)
    .then(r => r.json());
```

## HIPAA Compliance

The vaccination system is designed with HIPAA compliance in mind:

1. **Access Control**: Vaccinations are associated with pets owned by users
2. **Audit Trail**: All changes are logged with timestamps
3. **Data Encryption**: Sensitive data encrypted at rest and in transit
4. **Adverse Event Logging**: Complete tracking for regulatory compliance
5. **Certificate Codes**: Anonymous verification without exposing personal data
6. **Data Retention**: Support for retention policies and secure deletion

## Error Handling

The system uses standard HTTP status codes:

- `200 OK`: Successful GET request
- `201 Created`: Successful POST request (resource created)
- `204 No Content`: Successful DELETE request
- `400 Bad Request`: Invalid input
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

Example error response:
```json
{
    "statusCode": 400,
    "message": "Vaccination with ID xyz not found",
    "error": "BadRequestException"
}
```

## Configuration

The vaccination system can be configured through environment variables:

```env
# Certificate storage
CERTIFICATE_STORAGE_PATH=./certificates
CERTIFICATE_STORAGE_TYPE=local|s3|gcs

# Reminder settings
REMINDER_DAYS_BEFORE_DUE=7
REMINDER_BATCH_SIZE=50

# Notifications
ENABLE_EMAIL_NOTIFICATIONS=true
ENABLE_SMS_NOTIFICATIONS=false
ENABLE_PUSH_NOTIFICATIONS=true
```

## Future Enhancements

1. **Mobile App Integration**: QR code scanning for certificate verification
2. **AI-Powered Scheduling**: ML-based optimal vaccination timing recommendations
3. **Multi-Clinic Support**: Unified vaccination records across multiple clinics
4. **Vaccine Registry**: Integration with national vaccine registries
5. **Adverse Event Dashboard**: Analytics on vaccine reactions
6. **Automated Scheduling**: Integration with vet clinic scheduling systems
7. **Insurance Integration**: Vaccination record verification for pet insurance
8. **Mobile Vaccination Clinics**: Support for traveling clinic operations

## Testing

### Run Unit Tests
```bash
npm test -- vaccinations
```

### Run E2E Tests
```bash
npm run test:e2e -- vaccinations
```

### Manual Testing Checklist

- [ ] Create vaccination for a pet
- [ ] Generate and download certificate
- [ ] Log adverse reaction
- [ ] Check reminder status
- [ ] Send reminder notification
- [ ] Update vaccination details
- [ ] Delete vaccination
- [ ] Retrieve breed-specific schedules
- [ ] Batch reminder sending
- [ ] Certificate code lookup

## Support

For issues or questions about the vaccination system:
1. Check the API documentation
2. Review error messages in application logs
3. Contact the development team
4. Submit an issue on the project repository

## License

This vaccination management system is part of the PetChain project and is subject to the project's license terms.
