-- ============================================================================
-- VACCINATIONS TABLE
-- ============================================================================
-- Tracks all vaccinations administered to pets
-- Supports HIPAA-compliant health record keeping

CREATE TABLE vaccinations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Pet reference
    petId UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
    
    -- Vaccine information
    vaccineName VARCHAR(255) NOT NULL,
    manufacturer VARCHAR(255),
    batchNumber VARCHAR(255),
    
    -- Administration details
    dateAdministered DATE NOT NULL,
    nextDueDate DATE,
    expirationDate DATE,
    
    -- Site of injection
    site VARCHAR(255),
    
    -- Veterinarian information
    veterinarianName VARCHAR(255) NOT NULL,
    vetClinicId UUID REFERENCES vet_clinics(id),
    
    -- Certificate information
    certificateUrl VARCHAR(500),
    certificateCode VARCHAR(50) UNIQUE,
    
    -- Reminder tracking
    reminderSent BOOLEAN DEFAULT false,
    
    -- Additional notes
    notes TEXT,
    
    -- Audit fields
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_vaccinations_pet FOREIGN KEY(petId) REFERENCES pets(id) ON DELETE CASCADE,
    CONSTRAINT fk_vaccinations_vet_clinic FOREIGN KEY(vetClinicId) REFERENCES vet_clinics(id)
);

-- Indexes for common queries
CREATE INDEX idx_vaccinations_pet_id ON vaccinations(petId);
CREATE INDEX idx_vaccinations_next_due_date ON vaccinations(nextDueDate);
CREATE INDEX idx_vaccinations_reminder_sent ON vaccinations(reminderSent);
CREATE INDEX idx_vaccinations_vet_clinic ON vaccinations(vetClinicId);
CREATE INDEX idx_vaccinations_certificate_code ON vaccinations(certificateCode);
CREATE INDEX idx_vaccinations_date_administered ON vaccinations(dateAdministered);


-- ============================================================================
-- VACCINATION_REACTIONS TABLE
-- ============================================================================
-- Tracks adverse reactions to vaccinations
-- Supports HIPAA-compliant adverse event logging and reporting

CREATE TABLE vaccination_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Vaccination reference
    vaccinationId UUID NOT NULL REFERENCES vaccinations(id) ON DELETE CASCADE,
    
    -- Reaction details
    severity ENUM('MILD', 'MODERATE', 'SEVERE') NOT NULL,
    description TEXT NOT NULL,
    
    -- Timing information
    onsetHours INTEGER,
    durationHours INTEGER,
    
    -- Treatment and follow-up
    treatment TEXT,
    requiredVeterinaryIntervention BOOLEAN DEFAULT false,
    notes TEXT,
    
    -- Manufacturer reporting
    reportedToManufacturer BOOLEAN DEFAULT false,
    manufacturerReportId VARCHAR(255),
    
    -- Audit fields
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_reactions_vaccination FOREIGN KEY(vaccinationId) REFERENCES vaccinations(id) ON DELETE CASCADE
);

-- Indexes for common queries
CREATE INDEX idx_reactions_vaccination_id ON vaccination_reactions(vaccinationId);
CREATE INDEX idx_reactions_severity ON vaccination_reactions(severity);
CREATE INDEX idx_reactions_reported ON vaccination_reactions(reportedToManufacturer);


-- ============================================================================
-- VACCINATION_SCHEDULES TABLE
-- ============================================================================
-- Defines standard vaccination schedules by breed and species
-- Provides recommended vaccination timing and intervals

CREATE TABLE vaccination_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Breed association (optional - NULL means general schedule)
    breedId UUID REFERENCES breeds(id) ON DELETE SET NULL,
    
    -- Vaccine information
    vaccineName VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Timing information
    recommendedAgeWeeks INTEGER NOT NULL,
    intervalWeeks INTEGER,
    dosesRequired INTEGER DEFAULT 1,
    
    -- Status and priority
    isRequired BOOLEAN DEFAULT false,
    isActive BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 1,
    
    -- Audit fields
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_schedules_breed FOREIGN KEY(breedId) REFERENCES breeds(id) ON DELETE SET NULL
);

-- Indexes for common queries
CREATE INDEX idx_schedules_breed ON vaccination_schedules(breedId);
CREATE INDEX idx_schedules_vaccine_name ON vaccination_schedules(vaccineName);
CREATE INDEX idx_schedules_is_active ON vaccination_schedules(isActive);
CREATE INDEX idx_schedules_is_required ON vaccination_schedules(isRequired);


-- ============================================================================
-- DATA VALIDATION CONSTRAINTS
-- ============================================================================

-- Ensure next due date is after administered date
ALTER TABLE vaccinations
ADD CONSTRAINT check_dates_valid
CHECK (nextDueDate IS NULL OR nextDueDate > dateAdministered);

-- Ensure expiration date is after administered date
ALTER TABLE vaccinations
ADD CONSTRAINT check_expiration_valid
CHECK (expirationDate IS NULL OR expirationDate >= dateAdministered);

-- Ensure doses required is positive
ALTER TABLE vaccination_schedules
ADD CONSTRAINT check_doses_positive
CHECK (dosesRequired > 0);

-- Ensure recommended age is non-negative
ALTER TABLE vaccination_schedules
ADD CONSTRAINT check_age_valid
CHECK (recommendedAgeWeeks >= 0);
