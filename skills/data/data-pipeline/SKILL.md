---
name: data-pipeline
description: Design and implement data pipelines for ETL/ELT processes
user-invocable: true
categories: [data-engineering, etl, python]
version: 1.0.0
---

# Data Pipeline Creation

Design and implement robust, scalable data pipelines for ETL/ELT processes following data engineering best practices.

## Usage

```
/data-pipeline <pipeline-name> <description>
```

### Examples

```
/data-pipeline user-analytics "Extract user behavior data, transform and load to data warehouse"
/data-pipeline sales-aggregation "Daily sales data aggregation from multiple sources"
/data-pipeline ml-feature-store "Feature engineering pipeline for ML models"
```

## Pipeline Architecture

```
┌─────────┐     ┌───────────┐     ┌────────┐     ┌──────────┐
│ Sources │────▶│ Transform │────▶│ Validate│────▶│ Load     │
└─────────┘     └───────────┘     └────────┘     └──────────┘
                      │                  │              │
                      ▼                  ▼              ▼
                   Logging            Metrics      Data Quality
```

## Project Structure

```
pipeline/
├── config/
│   ├── __init__.py
│   ├── settings.py          # Configuration
│   └── schemas.py           # Data schemas
├── extractors/
│   ├── __init__.py
│   ├── base.py              # Base extractor
│   ├── database.py          # DB extractor
│   └── api.py               # API extractor
├── transformers/
│   ├── __init__.py
│   ├── base.py              # Base transformer
│   ├── cleaning.py          # Data cleaning
│   └── enrichment.py        # Data enrichment
├── loaders/
│   ├── __init__.py
│   ├── base.py              # Base loader
│   ├── database.py          # DB loader
│   └── warehouse.py         # Data warehouse loader
├── validators/
│   ├── __init__.py
│   └── quality.py           # Data quality checks
├── utils/
│   ├── __init__.py
│   ├── logging.py           # Logging utilities
│   └── metrics.py           # Metrics collection
├── pipelines/
│   ├── __init__.py
│   └── user_analytics.py    # Specific pipelines
├── tests/
│   ├── test_extractors.py
│   ├── test_transformers.py
│   └── test_loaders.py
├── requirements.txt
└── main.py                  # Entry point
```

## 1. Base Classes

### Base Extractor

```python
from abc import ABC, abstractmethod
from typing import Iterator, Any, Dict
import logging

logger = logging.getLogger(__name__)


class BaseExtractor(ABC):
    """Base class for data extractors."""

    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.metrics = {'records_extracted': 0, 'errors': 0}

    @abstractmethod
    def extract(self) -> Iterator[Dict[str, Any]]:
        """
        Extract data from source.

        Yields:
            Dict containing record data
        """
        pass

    def _record_metric(self, metric_name: str, value: int = 1):
        """Record pipeline metric."""
        self.metrics[metric_name] = self.metrics.get(metric_name, 0) + value

    def _log_progress(self, records_processed: int):
        """Log extraction progress."""
        if records_processed % 1000 == 0:
            logger.info(f"Extracted {records_processed} records")
```

### Base Transformer

```python
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)


class BaseTransformer(ABC):
    """Base class for data transformers."""

    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.metrics = {'records_transformed': 0, 'records_filtered': 0, 'errors': 0}

    @abstractmethod
    def transform(self, record: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Transform a single record.

        Args:
            record: Input record

        Returns:
            Transformed record or None if record should be filtered
        """
        pass

    def transform_batch(self, records: list[Dict[str, Any]]) -> list[Dict[str, Any]]:
        """
        Transform a batch of records.

        Args:
            records: List of input records

        Returns:
            List of transformed records
        """
        transformed = []
        for record in records:
            try:
                result = self.transform(record)
                if result is not None:
                    transformed.append(result)
                    self.metrics['records_transformed'] += 1
                else:
                    self.metrics['records_filtered'] += 1
            except Exception as e:
                logger.error(f"Error transforming record: {e}")
                self.metrics['errors'] += 1

        return transformed
```

### Base Loader

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)


class BaseLoader(ABC):
    """Base class for data loaders."""

    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.metrics = {'records_loaded': 0, 'batches_loaded': 0, 'errors': 0}

    @abstractmethod
    def load(self, records: List[Dict[str, Any]]):
        """
        Load records to destination.

        Args:
            records: List of records to load
        """
        pass

    def load_batch(self, records: List[Dict[str, Any]], batch_size: int = 1000):
        """
        Load records in batches.

        Args:
            records: List of records to load
            batch_size: Size of each batch
        """
        for i in range(0, len(records), batch_size):
            batch = records[i:i + batch_size]
            try:
                self.load(batch)
                self.metrics['records_loaded'] += len(batch)
                self.metrics['batches_loaded'] += 1
            except Exception as e:
                logger.error(f"Error loading batch: {e}")
                self.metrics['errors'] += 1
                raise
```

## 2. Concrete Implementations

### Database Extractor

```python
import psycopg2
from typing import Iterator, Dict, Any
from .base import BaseExtractor


class PostgresExtractor(BaseExtractor):
    """Extract data from PostgreSQL database."""

    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.connection = None

    def connect(self):
        """Establish database connection."""
        self.connection = psycopg2.connect(
            host=self.config['host'],
            port=self.config['port'],
            database=self.config['database'],
            user=self.config['user'],
            password=self.config['password']
        )

    def extract(self) -> Iterator[Dict[str, Any]]:
        """Extract records from database."""
        if not self.connection:
            self.connect()

        query = self.config['query']
        batch_size = self.config.get('batch_size', 1000)

        with self.connection.cursor() as cursor:
            cursor.execute(query)
            columns = [desc[0] for desc in cursor.description]

            while True:
                rows = cursor.fetchmany(batch_size)
                if not rows:
                    break

                for row in rows:
                    record = dict(zip(columns, row))
                    self.metrics['records_extracted'] += 1
                    yield record

        self.connection.close()


class IncrementalExtractor(PostgresExtractor):
    """Extract data incrementally based on timestamp."""

    def extract(self) -> Iterator[Dict[str, Any]]:
        """Extract only new/updated records since last run."""
        last_extracted = self._get_last_extraction_timestamp()

        self.config['query'] = f"""
            SELECT *
            FROM {self.config['table']}
            WHERE {self.config['timestamp_column']} > '{last_extracted}'
            ORDER BY {self.config['timestamp_column']}
        """

        yield from super().extract()

        # Update last extraction timestamp
        self._save_last_extraction_timestamp()

    def _get_last_extraction_timestamp(self):
        """Get timestamp of last extraction."""
        # Implementation depends on your state management
        pass

    def _save_last_extraction_timestamp(self):
        """Save current timestamp as last extraction."""
        pass
```

### Data Cleaning Transformer

```python
import re
from typing import Dict, Any, Optional
from datetime import datetime
from .base import BaseTransformer


class DataCleaningTransformer(BaseTransformer):
    """Clean and standardize data."""

    def transform(self, record: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Clean and standardize record."""
        # Remove null values
        record = {k: v for k, v in record.items() if v is not None}

        # Standardize email
        if 'email' in record:
            record['email'] = self._clean_email(record['email'])

        # Standardize phone
        if 'phone' in record:
            record['phone'] = self._clean_phone(record['phone'])

        # Parse dates
        if 'created_at' in record and isinstance(record['created_at'], str):
            record['created_at'] = self._parse_date(record['created_at'])

        # Trim strings
        for key, value in record.items():
            if isinstance(value, str):
                record[key] = value.strip()

        return record

    @staticmethod
    def _clean_email(email: str) -> str:
        """Standardize email format."""
        return email.lower().strip()

    @staticmethod
    def _clean_phone(phone: str) -> str:
        """Standardize phone format."""
        # Remove non-numeric characters
        return re.sub(r'\D', '', phone)

    @staticmethod
    def _parse_date(date_str: str) -> datetime:
        """Parse date string to datetime."""
        formats = ['%Y-%m-%d', '%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S']
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt)
            except ValueError:
                continue
        raise ValueError(f"Unable to parse date: {date_str}")
```

### Data Warehouse Loader

```python
from sqlalchemy import create_engine, Table, MetaData
from sqlalchemy.dialects.postgresql import insert
from typing import List, Dict, Any
from .base import BaseLoader


class DataWarehouseLoader(BaseLoader):
    """Load data to data warehouse."""

    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.engine = create_engine(config['connection_string'])
        self.metadata = MetaData()

    def load(self, records: List[Dict[str, Any]]):
        """Load records using upsert (insert or update)."""
        if not records:
            return

        table_name = self.config['table']
        table = Table(table_name, self.metadata, autoload_with=self.engine)

        with self.engine.begin() as connection:
            # PostgreSQL upsert
            stmt = insert(table).values(records)
            stmt = stmt.on_conflict_do_update(
                index_elements=['id'],  # Primary key
                set_={
                    col.name: col
                    for col in stmt.excluded
                    if col.name not in ['id', 'created_at']
                }
            )
            connection.execute(stmt)

    def load_append_only(self, records: List[Dict[str, Any]]):
        """Load records without updating existing ones."""
        if not records:
            return

        table_name = self.config['table']
        table = Table(table_name, self.metadata, autoload_with=self.engine)

        with self.engine.begin() as connection:
            connection.execute(table.insert(), records)
```

## 3. Data Validation

```python
from typing import Dict, Any, List
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)


@dataclass
class ValidationRule:
    """Data validation rule."""
    field: str
    rule_type: str  # 'not_null', 'type', 'range', 'regex', 'custom'
    params: Dict[str, Any]


class DataValidator:
    """Validate data quality."""

    def __init__(self, rules: List[ValidationRule]):
        self.rules = rules
        self.metrics = {
            'records_validated': 0,
            'validation_errors': 0,
            'errors_by_rule': {}
        }

    def validate(self, record: Dict[str, Any]) -> bool:
        """
        Validate a single record.

        Returns:
            True if record is valid, False otherwise
        """
        is_valid = True

        for rule in self.rules:
            if not self._apply_rule(record, rule):
                is_valid = False
                self.metrics['validation_errors'] += 1
                rule_key = f"{rule.field}_{rule.rule_type}"
                self.metrics['errors_by_rule'][rule_key] = \
                    self.metrics['errors_by_rule'].get(rule_key, 0) + 1

        self.metrics['records_validated'] += 1
        return is_valid

    def _apply_rule(self, record: Dict[str, Any], rule: ValidationRule) -> bool:
        """Apply single validation rule."""
        value = record.get(rule.field)

        if rule.rule_type == 'not_null':
            return value is not None

        elif rule.rule_type == 'type':
            expected_type = rule.params['type']
            return isinstance(value, expected_type)

        elif rule.rule_type == 'range':
            if value is None:
                return False
            min_val = rule.params.get('min')
            max_val = rule.params.get('max')
            return (min_val is None or value >= min_val) and \
                   (max_val is None or value <= max_val)

        elif rule.rule_type == 'regex':
            import re
            pattern = rule.params['pattern']
            return bool(re.match(pattern, str(value)))

        elif rule.rule_type == 'custom':
            func = rule.params['function']
            return func(value)

        return True
```

## 4. Complete Pipeline Example

```python
from datetime import datetime
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)


class UserAnalyticsPipeline:
    """Complete ETL pipeline for user analytics."""

    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.extractor = PostgresExtractor(config['extractor'])
        self.transformers = [
            DataCleaningTransformer(config['cleaning']),
            EnrichmentTransformer(config['enrichment'])
        ]
        self.validator = DataValidator(config['validation_rules'])
        self.loader = DataWarehouseLoader(config['loader'])
        self.metrics = {}

    def run(self):
        """Execute the complete pipeline."""
        logger.info("Starting pipeline execution")
        start_time = datetime.now()

        try:
            # Extract
            logger.info("Extracting data...")
            records = list(self.extractor.extract())
            logger.info(f"Extracted {len(records)} records")

            # Transform
            logger.info("Transforming data...")
            for transformer in self.transformers:
                records = transformer.transform_batch(records)
            logger.info(f"Transformed to {len(records)} records")

            # Validate
            logger.info("Validating data...")
            valid_records = [r for r in records if self.validator.validate(r)]
            logger.info(f"Validated {len(valid_records)} records")

            # Load
            logger.info("Loading data...")
            self.loader.load_batch(valid_records)
            logger.info(f"Loaded {len(valid_records)} records")

            # Collect metrics
            self._collect_metrics()

            duration = (datetime.now() - start_time).total_seconds()
            logger.info(f"Pipeline completed in {duration:.2f} seconds")

        except Exception as e:
            logger.error(f"Pipeline failed: {e}")
            raise

    def _collect_metrics(self):
        """Collect and log pipeline metrics."""
        self.metrics = {
            'extractor': self.extractor.metrics,
            'transformers': [t.metrics for t in self.transformers],
            'validator': self.validator.metrics,
            'loader': self.loader.metrics
        }

        logger.info(f"Pipeline metrics: {self.metrics}")
```

## 5. Error Handling and Retry

```python
import time
from functools import wraps
import logging

logger = logging.getLogger(__name__)


def retry_on_failure(max_retries=3, delay=1, backoff=2):
    """Decorator for retrying failed operations."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            retries = 0
            current_delay = delay

            while retries < max_retries:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    retries += 1
                    if retries >= max_retries:
                        logger.error(f"Max retries reached for {func.__name__}")
                        raise

                    logger.warning(
                        f"Retry {retries}/{max_retries} for {func.__name__} "
                        f"after error: {e}"
                    )
                    time.sleep(current_delay)
                    current_delay *= backoff

        return wrapper
    return decorator


# Usage
class RobustExtractor(BaseExtractor):
    @retry_on_failure(max_retries=3, delay=2)
    def extract(self):
        # Extraction logic that might fail
        pass
```

## 6. Monitoring and Logging

```python
import logging
from datetime import datetime
from typing import Dict, Any


class PipelineLogger:
    """Structured logging for pipelines."""

    def __init__(self, pipeline_name: str):
        self.pipeline_name = pipeline_name
        self.logger = logging.getLogger(pipeline_name)
        self.run_id = datetime.now().strftime('%Y%m%d_%H%M%S')

    def log_start(self):
        """Log pipeline start."""
        self.logger.info(f"Pipeline {self.pipeline_name} started", extra={
            'run_id': self.run_id,
            'event': 'pipeline_start'
        })

    def log_step(self, step_name: str, metrics: Dict[str, Any]):
        """Log pipeline step completion."""
        self.logger.info(f"Step {step_name} completed", extra={
            'run_id': self.run_id,
            'event': 'step_complete',
            'step': step_name,
            'metrics': metrics
        })

    def log_completion(self, duration: float, total_records: int):
        """Log pipeline completion."""
        self.logger.info(f"Pipeline completed successfully", extra={
            'run_id': self.run_id,
            'event': 'pipeline_complete',
            'duration_seconds': duration,
            'total_records': total_records
        })

    def log_failure(self, error: Exception):
        """Log pipeline failure."""
        self.logger.error(f"Pipeline failed: {error}", extra={
            'run_id': self.run_id,
            'event': 'pipeline_failure',
            'error': str(error)
        })
```

## Best Practices

### 1. Idempotency
Ensure pipelines can be re-run safely without duplicating data.

### 2. Incremental Processing
Process only new/changed data when possible.

### 3. Data Quality Checks
Validate data at each step of the pipeline.

### 4. Error Handling
Implement retry logic and graceful degradation.

### 5. Monitoring
Track metrics and log important events.

### 6. Testing
Write tests for each component.

### 7. Configuration
Use configuration files for environment-specific settings.

### 8. Documentation
Document data schemas and transformation logic.

### 9. Performance
Use batch processing and optimize database queries.

### 10. State Management
Track pipeline state for recovery and auditing.

## Tools and Libraries

- **pandas**: Data manipulation
- **sqlalchemy**: Database ORM
- **psycopg2**: PostgreSQL adapter
- **apache-airflow**: Workflow orchestration
- **great_expectations**: Data validation
- **dbt**: Data transformation
- **prefect**: Workflow management

## Notes

- Follow clean code principles
- Write comprehensive tests
- Implement proper error handling
- Log all important operations
- Monitor pipeline performance
- Document data lineage
- Use version control for pipelines
- Implement data quality checks
