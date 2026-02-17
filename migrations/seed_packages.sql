-- Seed Data for Packages

-- Assuming we have some services. If not, this might need adjustment.
-- We will use a DO block to fetch service IDs if possible, or just insert dummy data that needs to be updated.

-- For now, let's insert packages with empty includedServiceIds or assumption.
-- Ideally, the user should run this after checking service IDs.

INSERT INTO packages (id, name, description, price, "includedServiceIds", "isActive")
VALUES
(
    uuid_generate_v4(),
    'Gold Detail Package',
    'Full Body Wash + Premium Wax + Interior Deep Clean. Save 100 ETB!',
    1200,
    '{}', -- Placeholder: Update with actual Service IDs
    true
),
(
    uuid_generate_v4(),
    'Silver Wash Package',
    'Body Wash + Liquid Wax. Save 50 ETB!',
    600,
    '{}', -- Placeholder: Update with actual Service IDs
    true
);
