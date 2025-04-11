USE Gym;
GO

-- 1.Calcular el precio total de la inscripcion
ALTER TRIGGER trg_calcular_total
ON INSCRIPCION
AFTER INSERT
AS
BEGIN
    UPDATE i
    SET Total = i.Subtotal * (1 - d.Porcentaje / 100.0)
    FROM INSCRIPCION i
    INNER JOIN inserted ins ON i.InscripcionID = ins.InscripcionID
    INNER JOIN DESCUENTOS d ON ins.DescuentoID = d.DescuentoID
    WHERE ins.DescuentoID IS NOT NULL; -- calcular Total con descuento

    UPDATE i
    SET Total = i.Subtotal
    FROM INSCRIPCION i
    INNER JOIN inserted ins ON i.InscripcionID = ins.InscripcionID
    WHERE ins.DescuentoID IS NULL; -- calcular sin descuento
END