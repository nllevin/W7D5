# == Schema Information
#
# Table name: cats
#
#  id          :integer      not null, primary key
#  name        :string
#  color       :string
#  breed       :string
#
# Table name: toys
#
#  id          :integer      not null, primary key
#  name        :string
#  color       :string
#  price       :integer
#
# Table name: cattoys
#
#  id          :integer      not null, primary key
#  cat_id      :integer      not null, foriegn key
#  toy_id      :integer      not null, foreign key

require_relative '../data/query_tuning_setup.rb'

# For this part of the project you'll be be asking yourself:
# TO QUERY OR NOT TO QUERY? 

# For that is the question!
# For each of the following problems you will try to write each
# problem WITH and WITHOUT subqueries, testing the efficiency
# of each query as you go. 

def frey_example
  # Find all the cats that are the same color as the cat named 'Freyja'.
  # Including 'Freyja' in the results.
  # DO NOT USE A SUBQUERY

  execute(<<-SQL)
    SELECT
      color_cats.name
    FROM
      cats AS freyja_cats
    JOIN
      cats AS color_cats ON freyja_cats.color = color_cats.color
    WHERE
      freyja_cats.name = 'Freyja';
  SQL
end

def frey_example_sub
  # Find all the cats that are the same color as the cat named 'Freyja'.
  # Including 'Freyja' in the results.

  # Using Explain you can see these queries are very similiar! Since our 
  # subquery is only performed on one table it is more efficient to use a subquery 
  # in this scenario instead of building the larger table.
  execute(<<-SQL)
    SELECT
      cats.name
    FROM
      cats
    WHERE
      cats.color = (
                    SELECT  
                      cats.color
                    FROM
                      cats
                    WHERE
                      name = 'Freyja'
                    );
  SQL
end

def harder_example
  # Find the toys and price for all the cats with the 
  # breed 'British Shorthair'.
  # Order alphabetically by toys name. 
  # DO NOT USE A SUBQUERY

  # Whereas in this query it is more efficient to not perform a subquery 
  # because we don't have to do the extra cost of a large subquery.
  execute(<<-SQL)
    SELECT
      toys.name, toys.price
    FROM
      cats
    JOIN
      cattoys ON cats.id = cattoys.cat_id
    JOIN
      toys ON toys.id = cattoys.toy_id
    WHERE
      cats.breed = 'British Shorthair'
    ORDER BY
      toys.name ASC;
  SQL
end

def harder_example_sub
  # Find the toys and price for all the cats with the 
  # breed 'British Shorthair'.
  # Order alphabetically by toys name. 

  # USE A SUBQUERY
  execute(<<-SQL)
    SELECT
      toys.name, toys.price
    FROM
      toys
    WHERE 
      toys.id IN (SELECT
                    toys.id
                  FROM 
                    toys
                  JOIN 
                    cattoys ON toys.id = cattoys.toy_id
                  JOIN 
                    cats ON cats.id = cattoys.cat_id
                  WHERE
                    cats.breed = 'British Shorthair')
    ORDER BY
      toys.name ASC;
  SQL
end


def no_apples_for_blair
  # Blair has was too many apple toys! Find the name of all the cats that
  # own toys named `Apple` that aren't `Blair`. 
  # Order by cat name alphabetically.

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT
      cats.name
    FROM
      cats
    INNER JOIN
      cattoys ON cattoys.cat_id = cats.id
    INNER JOIN
      toys ON cattoys.toy_id = toys.id
    WHERE
      toys.name = 'Apple' AND cats.name != 'Blair'
    ORDER BY
      cats.name ASC;
  SQL
end


def no_apples_for_blair_sub
  # Blair has was too many apple toys! Find the name of all the cats that
  # own toys named `Apple` that aren't `Blair`. 
  # Order by cat name alphabetically.

  # USE A SUBQUERY
  execute(<<-SQL)
    SELECT DISTINCT
      cats.name
    FROM
      cats
    WHERE
      cats.id IN (
        SELECT
          cats.id
        FROM
          cats
        INNER JOIN
          cattoys ON cattoys.cat_id = cats.id
        INNER JOIN
          toys ON cattoys.toy_id = toys.id
        WHERE
          toys.name = 'Apple'
      ) AND cats.name != 'Blair'
    ORDER BY
      cats.name ASC;
  SQL
end

    # INNER JOIN
    #   cattoys ON cattoys.cat_id = cats.id
    # INNER JOIN
    #   toys ON cattoys.toy_id = toys.id
    # WHERE
    #   toys.name = 'Apple' AND cats.name NOT IN (
    #     SELECT
    #       cats.name
    #     FROM
    #       cats
    #     WHERE
    #       cats.name = 'Blair'
    #   )

def toys_that_brendon_owns
  # List the all the toy names for all the cats named 'Brendon'.
  # Order alphabetically by toy name. 

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT
      toys.name
    FROM
      toys
    INNER JOIN
      cattoys ON cattoys.toy_id = toys.id
    INNER JOIN
      cats ON cats.id = cattoys.cat_id
    WHERE
      cats.name = 'Brendon'
    ORDER BY
      toys.name ASC;
  SQL
end

def toys_that_brendon_owns_sub
  # List the all the toy names for all the cats named 'Brendon'.
  # Order alphabetically by toy name. 

  # USE A SUBQUERY
  execute(<<-SQL)
    SELECT DISTINCT
      toys.name
    FROM
      toys
    WHERE
      toys.name IN (
        SELECT
          toys.name
        FROM
          toys
        INNER JOIN
          cattoys ON cattoys.toy_id = toys.id
        INNER JOIN
          cats ON cats.id = cattoys.cat_id
        WHERE
          cats.name = 'Brendon'
      )
    ORDER BY
      toys.name ASC;
  SQL
end

def price_like_shiny_mouse
  # There are multiple 'Shiny Mouse' toys that all have different prices.
  # Your goal is to list all names and prices of the toys with the same prices 
  # as the different 'Shiny Mouse' toys. 

  # Exclude the 'Shiny Mouse' toy from your results.
  # Order your alphabetically by toy name.

  # DO NOT USE A SUBQUERY
  execute(<<-SQL) 
    SELECT
      target_toys.name, target_toys.price
    FROM
      toys AS target_toys
    INNER JOIN
      toys AS shiny_toys ON target_toys.price = shiny_toys.price
    WHERE
      target_toys.name != 'Shiny Mouse' AND shiny_toys.name = 'Shiny Mouse'
    ORDER BY target_toys.name ASC;
  SQL
end

def price_like_shiny_mouse_sub
  # There are multiple 'Shiny Mouse' toys that all have different prices.
  # Your goal is to list all names and prices of the toys with the same prices 
  # as the different 'Shiny Mouse' toys. 

  # Exclude the 'Shiny Mouse' toy from your results.
  # Order your alphabetically by toy name.

  # USE A SUBQUERY
  execute(<<-SQL) 
    SELECT
      toys.name, toys.price
    FROM
      toys
    WHERE
      toys.price IN (
        SELECT
          toys.price
        FROM
          toys
        WHERE
          toys.name = 'Shiny Mouse'
      ) AND toys.name != 'Shiny Mouse'
    ORDER BY
      toys.name ASC;
  SQL
end

def just_like_orange
  # Find the breed of the cat named 'Orange'. 
  # Then list the cats names and the breed of all the cats of Orange's breed.
  # Exclude the cat named 'Orange' from your results.
  # Order by cats name alphabetically.

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT
      same_breed_cats.name, same_breed_cats.breed
    FROM
      cats AS cats_orange
    INNER JOIN
      cats AS same_breed_cats ON cats_orange.breed = same_breed_cats.breed
    WHERE
      cats_orange.name = 'Orange' AND same_breed_cats.name != 'Orange'
    ORDER BY
      same_breed_cats.name ASC;
  SQL
end

def just_like_orange_sub
  # Find the breed of the cat named 'Orange'. 
  # Then list the cats names and the breed of all the cats of Orange's  breed.
  # Exclude the cat named 'Orange' from your results.
  # Order by cats name alphabetically.

  # USE A SUBQUERY
  execute(<<-SQL)
    SELECT
      cats.name, cats.breed
    FROM
      cats
    WHERE
      cats.breed = (
        SELECT
          cats.breed
        FROM
          cats
        WHERE
          cats.name = 'Orange'
      ) AND cats.name != 'Orange'
    ORDER BY
      cats.name ASC;
  SQL
end



def toys_that_jet_owns
  # Find all of the toys that Jet owns. Then list the the names of all 
  # the other cats that own those toys as well as the toys names.
  # Exclude Jet from the results.
  # Order alphabetically by cat name. 

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT DISTINCT
      other_cats.name, toys.name
    FROM 
      cats AS cats_jet
    INNER JOIN
      cattoys as j_cattoys ON j_cattoys.cat_id = cats_jet.id
    INNER JOIN
      toys AS toys ON toys.id = j_cattoys.toy_id
    INNER JOIN
      cattoys as other_cattoys ON other_cattoys.toy_id = j_cattoys.toy_id
    INNER JOIN
      cats AS other_cats ON other_cattoys.cat_id = other_cats.id
    WHERE
      cats_jet.name = 'Jet' AND other_cats.name != 'Jet'
    ORDER BY
      other_cats.name ASC;
  SQL
end

def toys_that_jet_owns_sub
  # Find all of the toys that Jet owns. Then list the the names of all 
  # the other cats that own those toys as well as the toys names.
  # Exclude Jet from the results.
  # Order alphabetically by cat name. 

  # USE A SUBQUERY
  execute(<<-SQL)
    
  SQL
end