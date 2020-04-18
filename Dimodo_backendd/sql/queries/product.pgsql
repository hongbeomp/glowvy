--name: FindProductById
SELECT
    product.id,
    product.sprice,
    product.sname,
    product.thumbnail
FROM
    product
WHERE
    product.id = $1;

--name: QueryAllCategory
SELECT
    id,
    name,
    image
FROM
    Category;

--name: ProductsByCategoryID
SELECT DISTINCT
    product.id,
    product.sid,
    product.sprice,
    product.sale_price,
    product.sale_percent,
    COALESCE(product.purchase_count, 0) AS purchase_count,
    product.sname,
    product.thumbnail
FROM
    product,
    category,
    category_default
WHERE
    product.category_id = $1
ORDER BY
    id DESC OFFSET $2
LIMIT $3;

--name: ProductsByTags
SELECT DISTINCT
    product.id,
    product.sid,
    product.sprice,
    product.sale_price,
    product.sale_percent,
    COALESCE(product.purchase_count, 0) AS purchase_count,
    product.sname,
    product.thumbnail
FROM
    product,
    category,
    category_default
WHERE
    product.tags = $1
ORDER BY
    id DESC OFFSET $2
LIMIT $3;

--name: ProductsByShopId
SELECT DISTINCT
    product.id,
    product.sid,
    product.sprice,
    product.sale_price,
    product.sale_percent,
    COALESCE(product.purchase_count, 0) AS purchase_count,
    product.sname,
    product.thumbnail
FROM
    product,
    category,
    category_default
WHERE
    product.seller ->> 'id' = $1 OFFSET $2
LIMIT $3;

--name:	CategoryProductsQuery
SELECT
    id,
    sprice,
    sname,
    image
FROM
    product
WHERE
    category_id = $1
    AND deleted_at IS NULL OFFSET $2
LIMIT $3;

--name:	CountReviews
SELECT
    COUNT(*)
FROM (
    SELECT
        review.author,
        review.text,
        review.review_id,
        review.product_id,
        review.images
    FROM
        review
    WHERE
        review.product_id = $1 OFFSET $2
    LIMIT $3) subque;

--name: ReviewsByProductID
SELECT
    review.product_id,
    review.review_id,
    review.author,
    review.text,
    COALESCE(review.images, ARRAY[]::text[]) AS images
    --if images don't exist, return empty array
FROM
    review
WHERE
    review.product_id = $1 OFFSET $2
LIMIT $3;

--name:	Options
SELECT
    product.options
FROM
    product
WHERE
    product.sid = $1;

--name: ProductDetailById
SELECT
    product.Sid,
    product.sname,
    product.sprice,
    product.sale_percent,
    product.sale_price,
    product.description,
    product.thumbnail,
    product.slider_images,
    product.desc_images,
    product.seller,
    product.size_details,
    product.category_id,
    product.options
FROM
    product
WHERE
    product.sid = $1;

--name:	CheckIfShopExists
SELECT
    seller
FROM
    product
WHERE
    seller ->> 'id' = $1;
